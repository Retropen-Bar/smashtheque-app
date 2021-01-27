class AddCategoryToRewards < ActiveRecord::Migration[6.0]
  def change
    add_column :rewards, :category, :string
    Reward.update_all(category: 'online_1v1')
    change_column :rewards, :category, :string, null: false
    add_index :rewards, %i(category level1 level2), unique: true
    remove_index :rewards, %i(level1 level2)
    remove_column :rewards, :name
  end
end
