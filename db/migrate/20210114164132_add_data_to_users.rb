class AddDataToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string
    User.find_each do |user|
      user.update_attribute :name, DiscordUser.find(user['discord_user_id']).username
    end
    change_column :users, :name, :string, null: false
  end
end
