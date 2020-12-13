class RetropenBotJobs::RebuildOnlineTournamentsJob < ApplicationJob
  queue_as :tournaments

  def perform(online_tournaments_category_id: nil)
    RetropenBot.default.rebuild_online_tournaments(
      online_tournaments_category_id
    )
  end
end
