class RetropenBotJobs::RebuildDiscordGuildsCharsListJob < ApplicationJob
  queue_as :actors

  def perform(actors_category_id: nil)
    RetropenBot.default.rebuild_discord_guilds_chars_list(
      actors_category_id
    )
  end
end
