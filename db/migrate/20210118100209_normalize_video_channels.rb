class NormalizeVideoChannels < ActiveRecord::Migration[6.0]
  def change
    rename_column :twitch_channels, :display_name, :name
  end
end
