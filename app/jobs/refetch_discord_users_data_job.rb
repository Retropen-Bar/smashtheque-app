class RefetchDiscordUsersDataJob < ApplicationJob
  queue_as :discord

  def perform
    DiscordUser.find_each do |discord_user|
      if discord_user.needs_fetching?
        discord_user.fetch_discord_data
        discord_user.save!
        sleep 1
      end
    end
  end
end
