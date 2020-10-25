class RenameUsers < ActiveRecord::Migration[6.0]
  def change
    rename_table :admin_users, :users
    add_column :users, :is_admin, :boolean, null: false, default: false
    User.update_all(is_admin: true)
  end
end
