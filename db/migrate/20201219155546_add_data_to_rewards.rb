class AddDataToRewards < ActiveRecord::Migration[6.0]
  def change
    add_column :rewards, :level1, :integer, null: false
    add_column :rewards, :level2, :integer, null: false
    add_index :rewards, %i(level1 level2), unique: true
  end
end
