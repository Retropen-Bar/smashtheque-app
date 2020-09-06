class AddTwitterUsernames < ActiveRecord::Migration[6.0]
  def change
    add_column :discord_guilds, :twitter_username, :string
    add_column :players, :twitter_username, :string
    add_column :teams, :twitter_username, :string
  end
end
