# == Schema Information
#
# Table name: discord_guild_admins
#
#  id               :bigint           not null, primary key
#  role             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  discord_guild_id :bigint           not null
#  discord_user_id  :bigint           not null
#
# Indexes
#
#  index_dga_on_both_ids                           (discord_guild_id,discord_user_id) UNIQUE
#  index_discord_guild_admins_on_discord_guild_id  (discord_guild_id)
#  index_discord_guild_admins_on_discord_user_id   (discord_user_id)
#
class DiscordGuildAdmin < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :discord_guild
  belongs_to :discord_user

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    RetropenBotScheduler.rebuild_discord_guilds_chars_list
  end

end
