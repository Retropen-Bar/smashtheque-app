class RetropenBotJobs::RebuildTeamAdminsListJob < ApplicationJob
  queue_as :actors

  def perform(actors_category_id: nil)
    RetropenBot.default.rebuild_team_admins_list(
      actors_category_id
    )
  end
end
