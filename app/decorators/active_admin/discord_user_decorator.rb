class ActiveAdmin::DiscordUserDecorator < DiscordUserDecorator
  include ActiveAdmin::BaseDecorator

  decorates :discord_user

  def admin_link(options = {})
    super(
      options.merge(
        label: (
          options[:label] || avatar_and_name_or_id(size: options[:size] || 32)
        )
      )
    )
  end

  def user_admin_link(options = {})
    user&.admin_decorate&.admin_link(options)
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
