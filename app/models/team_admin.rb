class TeamAdmin < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :team
  belongs_to :discord_user

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord
  def update_discord
    RetropenBotScheduler.rebuild_team_admins_list
  end

end
