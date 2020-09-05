class ActiveAdmin::DiscordGuildDecorator < DiscordGuildDecorator
  include ActiveAdmin::BaseDecorator

  decorates :discord_guild

  def admin_link(options = {})
    super(
      options.merge(
        label: (
          options[:label] || full_name_or_id(size: options[:size] || 32)
        )
      )
    )
  end

  def related_admin_link(options = {})
    related&.admin_decorate&.admin_link(options)
  end

  def admins_admin_links(options = {})
    model.discord_guild_admins.map do |discord_guild_admin|
      link = discord_guild_admin.discord_user.admin_decorate.admin_link(options.merge(
        url: [:admin, discord_guild_admin]
      ))
      link += " [#{discord_guild_admin.role}]" unless discord_guild_admin.role.blank?
      link
    end
  end

end
