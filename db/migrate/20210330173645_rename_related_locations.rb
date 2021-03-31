class RenameRelatedLocations < ActiveRecord::Migration[6.0]
  def change
    [
      DiscordGuildRelated,
      TwitchChannel,
      YouTubeChannel
    ].each do |klass|
      klass.where(related_type: 'Location').update_all(related_type: 'Community')
    end
  end
end
