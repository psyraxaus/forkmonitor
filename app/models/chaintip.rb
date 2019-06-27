class Chaintip < ApplicationRecord
  belongs_to :block
  belongs_to :node
  belongs_to :parent_chaintip, class_name: 'Chaintip', foreign_key: 'parent_chaintip_id', optional: true  # When a node is behind, we assume it would agree with this chaintip, until getchaintips says otherwise

  enum coin: [:btc, :bch, :bsv]

  validates :status, uniqueness: { scope: :node}

  def nodes
    res = Node.where(block: self.block).order(client_type: :asc ,name: :asc, version: :desc).to_a # block.node should be the same as the active chaintip for a node
    Chaintip.where(status: "active", parent_chaintip: self).each do |child|
      res.append child.node
    end
    res
  end

  def as_json(options = nil)
    fields = [:id]
    super({ only: fields }.merge(options || {})).merge({block: block, nodes: nodes})
  end

  def self.process_chaintip_result(chaintip, node)
    block = Block.find_by(block_hash: chaintip["hash"], coin: node.coin.downcase.to_sym)
    case chaintip["status"]
    when "active"
      throw "Block missing for active chaintips, did you forget to call poll! ?" unless block.present?
      tip = node.chaintips.find_or_create_by(status: "active", coin: block.coin) # There can only be one
      tip.update block: block, parent_chaintip: nil
      # Check if any of the other nodes are ahead of us. Use their chaintip instead unless we consider it invalid:
      Chaintip.joins(:block).where(coin: tip.coin, status: "active").where("blocks.height > ?", block.height).each do |candidate_tip|
        break if node.chaintips.find_by(block: candidate_tip.block, status: "invalid")
        # Travers candidate tip down to find our tip
        parent = candidate_tip.block.parent
        while parent.present? && parent.height >= block.height
          if parent == block
            tip.update parent_chaintip: candidate_tip
            break
          end
          parent = parent.parent
        end
        break if tip.parent_chaintip
      end
    when "valid-fork"
      return nil if chaintip["height"] < node.block.height - 1000
      block = Block.find_or_create_block_and_ancestors!(chaintip["hash"], node)
      tip = node.chaintips.create(status: "valid-fork", block: block, coin: block.coin) # There can be multiple valid-block chaintips
    when "invalid"
      # Ignore if we don't know this block from a different node: (TODO: add it anyway, so we actively search this block)
      return nil if block.nil?

      tip = node.chaintips.create(status: "invalid", block: block, coin: block.coin)

      # Create an alert
      invalid_block = InvalidBlock.find_or_create_by(node: node, block: block)
      if !invalid_block.notified_at
        User.all.each do |user|
          UserMailer.with(user: user, invalid_block: invalid_block).invalid_block_email.deliver
        end
        invalid_block.update notified_at: Time.now
      end
    end
  end

  def self.process_getchaintips(chaintips, node)
     # Delete existing chaintip entries, except the active one (which is unique):
     node.chaintips.where.not(status: "active").delete_all
     chaintips.each do |chaintip|
       process_chaintip_result(chaintip, node)
     end
   end
end
