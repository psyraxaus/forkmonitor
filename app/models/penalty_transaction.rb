class PenaltyTransaction < LightningTransaction
  def get_opening_tx_id!()
    justice_tx = Bitcoin::Protocol::Tx.new([self.raw_tx].pack('H*'))
    close_tx_id = justice_tx.in[self.input].prev_out_hash.reverse.unpack("H*")[0]
    close_tx_raw = Node.first_with_txindex(:btc).getrawtransaction(close_tx_id)
    close_tx = Bitcoin::Protocol::Tx.new([close_tx_raw].pack('H*'))
    super(close_tx)
  end

  def self.check!(node, block, parsed_block)
    # Based on: https://github.com/alexbosworth/bolt03/blob/master/breaches/is_remedy_witness.js
    parsed_block.transactions.each do |tx|
      tx.in.each_with_index do |tx_in, input|
        # Must have a witness
        next if tx_in.script_witness.empty?
        # Witness must have the correct number of elements
        next unless tx_in.script_witness.stack.length == 3
        signature, flag, toLocalScript = tx_in.script_witness.stack
        # Signature must be DER encoded
        next unless Bitcoin::Script.is_der_signature?(signature)
        # Script path must be one of justice (non zero switches to OP_IF)
        next unless flag.unpack('H*')[0] == "01"

        script = Bitcoin::Script.new(toLocalScript)
        # Witness script must match expected pattern (BOLT #3)
        chunks = script.chunks
        next unless chunks.length == 9
        # OP_IF
        next unless chunks.shift() == Bitcoin::Script::OP_IF
        #  <revocationpubkey>
        next unless Bitcoin::Script.check_pubkey_encoding?(chunks.shift())
        #  OP_ELSE
        next unless chunks.shift() == Bitcoin::Script::OP_ELSE
        #      `to_self_delay`
        next if chunks.shift().instance_of? Bitcoin::Script
        #      OP_CHECKSEQUENCEVERIFY
        next unless chunks.shift() == Bitcoin::Script::OP_NOP3
        #      OP_DROP
        next unless chunks.shift() == Bitcoin::Script::OP_DROP
        #      <local_delayedpubkey>
        next unless Bitcoin::Script.check_pubkey_encoding?(chunks.shift())
        #  OP_ENDIF
        next unless chunks.shift() == Bitcoin::Script::OP_ENDIF
        #  OP_CHECKSIG
        next unless chunks.shift() == Bitcoin::Script::OP_CHECKSIG

        next unless PenaltyTransaction.where(tx_id: tx.hash, input: input).count == 0

        puts "Penalty: #{ tx.hash }" unless Rails.env.test?

        ln = block.penalty_transactions.build(
          tx_id: tx.hash,
          input: input,
          raw_tx: tx.payload.unpack('H*')[0],
          amount: get_input_amount(node, tx, input)
        )
        ln.opening_tx_id = ln.get_opening_tx_id!
        ln.save

        ln.find_parent!
      end
    end
  end

  private

  def expire_cache
    super
    Rails.cache.delete("api/v1/ln_penalties.json")
  end
end