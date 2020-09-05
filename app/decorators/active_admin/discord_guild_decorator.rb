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

end
