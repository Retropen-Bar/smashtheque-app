class FetchUnknownDiscordGuildsJob < ApplicationJob
  queue_as :discord

  def perform
    DiscordGuild.fetch_unknown
  end
end
