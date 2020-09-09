module ActiveAdmin::DiscordGuildsHelper

  def discord_guild_admins_select_collection
    DiscordUser.known.order(:username).decorate
  end

  def discord_guild_related_global_select_collection
    related_global_select_collection
  end

end
