class CleanAdminUsers < ActiveRecord::Migration[6.0]
  def change
    ## Database authenticatable
    remove_column :admin_users, :email

    ## Recoverable
    remove_column :admin_users, :reset_password_token
    remove_column :admin_users, :reset_password_sent_at

    ## Rememberable
    remove_column :admin_users, :remember_created_at

    ## Trackable
    add_column :admin_users, :sign_in_count, :integer, default: 0, null: false
    add_column :admin_users, :current_sign_in_at, :datetime
    add_column :admin_users, :last_sign_in_at, :datetime
    add_column :admin_users, :current_sign_in_ip, :inet
    add_column :admin_users, :last_sign_in_ip, :inet

    ## Data
    remove_column :admin_users, :avatar_url
    remove_column :admin_users, :name
    remove_column :admin_users, :discord_username
    remove_column :admin_users, :discord_discriminator

    ## Index
    remove_index :admin_users, :discord_user_id
    add_index :admin_users, :discord_user_id, unique: true
  end
end
