class AddNameToVideoChannels < ActiveRecord::Migration[6.0]
  def change
    add_column :twitch_channels, :name, :string
    TwitchChannel.update_all("name = username")
    change_column :twitch_channels, :name, :string, null: false

    add_column :you_tube_channels, :name, :string
    YouTubeChannel.update_all("name = username")
    change_column :you_tube_channels, :name, :string, null: false
  end
end
