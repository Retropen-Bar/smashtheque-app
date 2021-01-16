class RevertUserDiscordUserLink < ActiveRecord::Migration[6.0]
  def change
    add_reference :discord_users, :user
    add_foreign_key :discord_users, :users
    User.find_each do |user|
      next if user['discord_user_id'].nil?
      DiscordUser.where(id: user['discord_user_id'])
                 .update_all(user_id: user.id)
    end
    remove_column :users, :discord_user_id
  end
end
