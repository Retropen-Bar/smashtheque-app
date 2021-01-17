class AddUrlToYouTubeChannels < ActiveRecord::Migration[6.0]
  def change
    add_column :you_tube_channels, :url, :string
    YouTubeChannel.update_all("url = CONCAT('https://www.youtube.com/c/', username)")
    change_column :you_tube_channels, :url, :string, null: false
    remove_column :you_tube_channels, :username
  end
end
