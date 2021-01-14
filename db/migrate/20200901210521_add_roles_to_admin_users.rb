class AddRolesToAdminUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :admin_users, :is_root, :boolean, null: false, default: false
    add_column :admin_users, :level, :string
    change_column :admin_users, :level, :string, null: false
  end
end
