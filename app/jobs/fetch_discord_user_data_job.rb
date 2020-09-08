class FetchDiscordUserDataJob < ApplicationJob
  queue_as :discord

  def perform(discord_user)
    discord_user.fetch_discord_data
    discord_user.save!
    sleep 1
  end
end
