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

  def user_status
    arbre do
      if user = model.user
        a href: h.auto_url_for(user) do
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

  def administrated_teams_admin_links(options = {})
    model.administrated_teams.map do |team|
      team.admin_decorate.admin_link(options)
    end
  end

end
