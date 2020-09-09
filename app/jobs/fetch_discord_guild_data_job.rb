class FetchDiscordGuildDataJob < ApplicationJob
  queue_as :discord

  def perform(discord_guild)
    discord_guild.fetch_discord_data
    discord_guild.save!
    sleep 1
  end
end
