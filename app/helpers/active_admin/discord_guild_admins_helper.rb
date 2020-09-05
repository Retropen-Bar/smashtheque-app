module ActiveAdmin::DiscordGuildAdminsHelper

  def discord_guild_admin_discord_guild_select_collection
    DiscordGuild.known.order(:name).decorate
  end

  def discord_guild_admin_discord_user_select_collection
    DiscordUser.known.order(:username).decorate
  end

end
