class ActiveAdmin::DiscordUserDecorator < DiscordUserDecorator
  include ActiveAdmin::BaseDecorator

  decorates :discord_user

  def admin_link(options = {})
    super(
      options.merge(
        label: (
          options[:label] || full_name_or_id(size: options[:size])
        )
      )
    )
  end

  def admin_user_status
    arbre do
      if admin_user = model.admin_user
        a href: h.auto_url_for(admin_user) do
          status_tag :yes
        end
      else
        status_tag :no
      end
    end
  end

  def administrated_discord_guilds_admin_links(options = {})
    model.discord_guild_admins.map do |discord_guild_admin|
      link = discord_guild_admin.discord_guild.admin_decorate.admin_link(options.merge(
        url: [:admin, discord_guild_admin]
      ))
      link += " [#{discord_guild_admin.role}]" unless discord_guild_admin.role.blank?
      link
    end
  end

end
