class DropRewardEmoji < ActiveRecord::Migration[6.0]
  def change
    remove_column :rewards, :emoji, :string, null: false
  end
end
