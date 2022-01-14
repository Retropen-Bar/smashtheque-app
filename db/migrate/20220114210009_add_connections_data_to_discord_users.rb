class AddConnectionsDataToDiscordUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :discord_users, bulk: true do |t|
      t.string :twitter_username
      t.string :twitch_username
      t.string :youtube_username
    end
  end
end
