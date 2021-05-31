module ActiveAdmin
  class DiscordGuildAdminDecorator < DiscordGuildAdminDecorator
    include ActiveAdmin::BaseDecorator

    decorates :discord_guild

    # for the page title
    def name
      [
        model.discord_guild.name,
        model.discord_user.username
      ].join(' - ')
    end

    def discord_guild_admin_link(options = {})
      model.discord_guild.admin_decorate.admin_link(options)
    end

    def discord_user_admin_link(options = {})
      model.discord_user.admin_decorate.admin_link(options)
    end
  end
end
