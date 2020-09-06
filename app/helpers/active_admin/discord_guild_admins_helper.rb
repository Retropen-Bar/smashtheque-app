module ActiveAdmin::DiscordGuildAdminsHelper

  def discord_guild_admin_discord_guild_select_collection
    DiscordGuild.order(:name).map do |discord_guild|
      [
        discord_guild.decorate.name_or_id,
        discord_guild.id
      ]
    end
  end

  def discord_guild_admin_discord_user_select_collection
    DiscordUser.known.order(:username).decorate
  end

end
