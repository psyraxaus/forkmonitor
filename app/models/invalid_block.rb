class InvalidBlock < ApplicationRecord
  belongs_to :block
  belongs_to :node

  def as_json(options = nil)
    super({ only: [:id, :dismissed_at] }).merge({
      coin: block.coin.upcase,
      block: block,
      node: {
        id: node.id,
        name: node.name,
        name_with_version: node.name_with_version
      }
    })
  end

  def self.check!(coin)
    Block.where(coin: coin).where("array_length(marked_valid_by,1) > 0").where("array_length(marked_invalid_by,1) > 0").each do |block|
      node = Node.find(block.marked_invalid_by.first)
      # Create an alert
      invalid_block = InvalidBlock.find_or_create_by(node: node, block: block)
      if !invalid_block.notified_at
        User.all.each do |user|
          UserMailer.with(user: user, invalid_block: invalid_block).invalid_block_email.deliver
        end
        invalid_block.update notified_at: Time.now
        Subscription.blast("invalid-block-#{ invalid_block.id }",
                           "Invalid block",
                           "#{ invalid_block.node.name_with_version } considers #{ invalid_block.block.coin.upcase } block { @invalid_block.block.height } ({ @invalid_block.block.block_hash }) invalid",
        )
      end
    end

  end
end
