class RetropenBot
  # ---------------------------------------------------------------------------
  # CONSTANTS
  # ---------------------------------------------------------------------------

  ONLINE_TO_ROLE_ID = ENV['DISCORD_ONLINE_TO_ROLE_ID']
  OFFLINE_TO_ROLE_ID = ENV['DISCORD_OFFLINE_TO_ROLE_ID']

  # ---------------------------------------------------------------------------
  # CONSTRUCTOR
  # ---------------------------------------------------------------------------

  def initialize(guild_id: nil)
    @guild_id = guild_id || ENV['DISCORD_GUILD_ID']
  end

  def self.default
    @default ||= new
  end

  # ---------------------------------------------------------------------------
  # SHARED
  # ---------------------------------------------------------------------------

  def client
    @client ||= DiscordClient.new
  end

  # ---------------------------------------------------------------------------
  # ROLES
  # ---------------------------------------------------------------------------

  def toggle_role(discord_id, role_id, toggle)
    return false unless role_id

    client.toggle_user_role(
      toggle,
      guild_id: @guild_id,
      user_id: discord_id,
      role_id: role_id
    )
  end

  def update_member_roles(discord_id)
    discord_user = DiscordUser.find_by(discord_id: discord_id)
    return false unless discord_user&.user

    toggle_role(
      discord_id,
      ONLINE_TO_ROLE_ID,
      discord_user.administrated_recurring_tournaments.online.any?
    )
    toggle_role(
      discord_id,
      OFFLINE_TO_ROLE_ID,
      discord_user.administrated_recurring_tournaments.offline.any?
    )
  end
end
