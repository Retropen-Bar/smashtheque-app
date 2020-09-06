class DiscordGuildAdmin < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :discord_guild
  belongs_to :discord_user

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord
  def update_discord
    RetropenBotScheduler.rebuild_discord_guilds_chars_list
  end

end
