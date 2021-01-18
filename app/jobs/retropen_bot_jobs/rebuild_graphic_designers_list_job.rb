class RetropenBotJobs::RebuildGraphicDesignersListJob < ApplicationJob
  queue_as :actors

  def perform(actors_category_id: nil)
    RetropenBot.default.rebuild_graphic_designers_list(
      actors_category_id
    )
  end
end
