class RetropenBotJobs::RebuildCoachesListJob < ApplicationJob
  queue_as :actors

  def perform(actors_category_id: nil)
    RetropenBot.default.rebuild_coaches_list(
      actors_category_id
    )
  end
end
