module ActiveAdmin::DiscordGuildsHelper

  def discord_guild_admins_select_collection
    DiscordUser.known.order(:username).decorate
  end

end
