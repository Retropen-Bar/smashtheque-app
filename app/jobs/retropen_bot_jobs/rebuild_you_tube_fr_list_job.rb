class RetropenBotJobs::RebuildYouTubeFrListJob < ApplicationJob
  queue_as :actors

  def perform(actors_category_id: nil)
    RetropenBot.default.rebuild_youtube_fr_list(
      actors_category_id
    )
  end
end
