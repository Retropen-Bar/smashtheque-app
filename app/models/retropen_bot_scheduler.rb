class RetropenBotScheduler
  # ---------------------------------------------------------------------------
  # ACTORS
  # ---------------------------------------------------------------------------

  def self.rebuild_discord_guilds_chars_list(actors_category_id: nil)
    RetropenBotJobs::RebuildDiscordGuildsCharsListJob.perform_later(
      actors_category_id: actors_category_id
    )
  end

  def self.rebuild_casters_list(actors_category_id: nil)
    RetropenBotJobs::RebuildCastersListJob.perform_later(
      actors_category_id: actors_category_id
    )
  end

  def self.rebuild_coaches_list(actors_category_id: nil)
    RetropenBotJobs::RebuildCoachesListJob.perform_later(
      actors_category_id: actors_category_id
    )
  end

  def self.rebuild_graphic_designers_list(actors_category_id: nil)
    RetropenBotJobs::RebuildGraphicDesignersListJob.perform_later(
      actors_category_id: actors_category_id
    )
  end

  def self.rebuild_team_admins_list(actors_category_id: nil)
    RetropenBotJobs::RebuildTeamAdminsListJob.perform_later(
      actors_category_id: actors_category_id
    )
  end

  def self.rebuild_twitch_fr_list(actors_category_id: nil)
    RetropenBotJobs::RebuildTwitchFrListJob.perform_later(
      actors_category_id: actors_category_id
    )
  end

  def self.rebuild_twitch_world_list(actors_category_id: nil)
    RetropenBotJobs::RebuildTwitchWorldListJob.perform_later(
      actors_category_id: actors_category_id
    )
  end

  def self.rebuild_youtube_fr_list(actors_category_id: nil)
    RetropenBotJobs::RebuildYouTubeFrListJob.perform_later(
      actors_category_id: actors_category_id
    )
  end

  def self.rebuild_youtube_world_list(actors_category_id: nil)
    RetropenBotJobs::RebuildYouTubeWorldListJob.perform_later(
      actors_category_id: actors_category_id
    )
  end

  def self.rebuild_twitch(actors_category_id: nil)
    _actors_category_id = actors_category_id || RetropenBot.default.actors_category['id']
    rebuild_twitch_fr_list actors_category_id: actors_category_id
    rebuild_twitch_world_list actors_category_id: actors_category_id
  end

  def self.rebuild_youtube(actors_category_id: nil)
    _actors_category_id = actors_category_id || RetropenBot.default.actors_category['id']
    rebuild_youtube_fr_list actors_category_id: actors_category_id
    rebuild_youtube_world_list actors_category_id: actors_category_id
  end

  def self.rebuild_actors(actors_category_id: nil)
    _actors_category_id = actors_category_id || RetropenBot.default.actors_category['id']
    rebuild_discord_guilds_chars_list actors_category_id: _actors_category_id
    rebuild_casters_list actors_category_id: _actors_category_id
    rebuild_coaches_list actors_category_id: _actors_category_id
    rebuild_graphic_designers_list actors_category_id: _actors_category_id
    rebuild_team_admins_list actors_category_id: _actors_category_id
    rebuild_twitch actors_category_id: _actors_category_id
    rebuild_youtube actors_category_id: _actors_category_id
  end

  # ---------------------------------------------------------------------------
  # ROLES
  # ---------------------------------------------------------------------------

  def self.update_member_roles(discord_id:)
    return false unless discord_id

    RetropenBotJobs::UpdateMemberRolesJob.perform_later(discord_id: discord_id)
  end
end
