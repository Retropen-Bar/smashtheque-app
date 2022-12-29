class RetropenBotScheduler
  # ---------------------------------------------------------------------------
  # ROLES
  # ---------------------------------------------------------------------------

  def self.update_member_roles(discord_id:)
    return false unless discord_id

    RetropenBotJobs::UpdateMemberRolesJob.perform_later(discord_id: discord_id)
  end
end
