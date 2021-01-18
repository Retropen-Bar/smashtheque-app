class RetropenBotJobs::RebuildCastersListJob < ApplicationJob
  queue_as :actors

  def perform(actors_category_id: nil)
    RetropenBot.default.rebuild_casters_list(
      actors_category_id
    )
  end
end
