class RenameUsers < ActiveRecord::Migration[6.0]
  def change
    rename_table :admin_users, :users
    rename_column :users, :level, :admin_level
    change_column :users, :admin_level, :string, null: true
  end
end
