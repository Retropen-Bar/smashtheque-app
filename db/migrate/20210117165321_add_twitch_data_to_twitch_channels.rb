class AddTwitchDataToTwitchChannels < ActiveRecord::Migration[6.0]
  def change
    add_column :twitch_channels, :twitch_id, :string
    add_column :twitch_channels, :display_name, :string
    add_column :twitch_channels, :twitch_description, :string
    add_column :twitch_channels, :profile_image_url, :string
    add_column :twitch_channels, :twitch_created_at, :datetime
    rename_column :twitch_channels, :username, :slug
    remove_column :twitch_channels, :name
  end
end
