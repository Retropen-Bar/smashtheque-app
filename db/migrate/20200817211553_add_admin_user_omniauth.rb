class AddAdminUserOmniauth < ActiveRecord::Migration[6.0]
  def change
    add_column :admin_users, :avatar_url, :string
    add_column :admin_users, :name, :string
    add_column :admin_users, :discord_username, :string
    add_column :admin_users, :discord_discriminator, :string
  end
end
