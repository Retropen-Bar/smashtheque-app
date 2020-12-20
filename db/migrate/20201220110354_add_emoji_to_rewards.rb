class AddEmojiToRewards < ActiveRecord::Migration[6.0]
  def change
    add_column :rewards, :emoji, :string
    Reward.update_all(emoji: '790174880787857429')
    change_column :rewards, :emoji, :string, null: false

    remove_column :rewards, :image
    remove_column :rewards, :style
  end
end
