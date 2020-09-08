class FetchUnknownDiscordUsersJob < ApplicationJob
  queue_as :discord

  def perform
    DiscordUser.fetch_unknown
  end
end
