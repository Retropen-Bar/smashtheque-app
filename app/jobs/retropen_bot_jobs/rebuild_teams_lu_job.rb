class RetropenBotJobs::RebuildTeamsLuJob < ApplicationJob
  queue_as :teams

  def perform(teams_category_id: nil)
    RetropenBot.default.rebuild_teams_lu(
      teams_category_id
    )
  end
end
