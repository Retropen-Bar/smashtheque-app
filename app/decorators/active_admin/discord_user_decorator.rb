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

end
