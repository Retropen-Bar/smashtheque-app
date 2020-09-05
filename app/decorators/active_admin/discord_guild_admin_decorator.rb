class ActiveAdmin::DiscordGuildAdminDecorator < DiscordGuildAdminDecorator
  include ActiveAdmin::BaseDecorator

  decorates :discord_guild

  def discord_guild_admin_link(options = {})
    model.discord_guild.admin_decorate.admin_link(options)
  end

  def discord_user_admin_link(options = {})
    model.discord_user.admin_decorate.admin_link(options)
  end

end
