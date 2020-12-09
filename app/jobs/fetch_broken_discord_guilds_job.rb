class FetchBrokenDiscordGuildsJob < ApplicationJob
  queue_as :discord

  def perform
    DiscordGuild.fetch_broken
  end
end
