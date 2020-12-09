class FetchBrokenDiscordUsersJob < ApplicationJob
  queue_as :discord

  def perform
    DiscordUser.fetch_broken
  end
end
