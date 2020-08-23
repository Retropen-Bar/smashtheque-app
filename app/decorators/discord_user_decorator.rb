class DiscordUserDecorator < BaseDecorator

  def admin_link(options = {})
    super(
      options.merge(
        label: (
          options[:label] || full_name(size: options[:size])
        )
      )
    )
  end

  def full_name(size: nil)
    [
      avatar_tag(size),
      discriminated_username
    ].join('&nbsp;').html_safe
  end

  def discriminated_username
    [
      model.username,
      discriminator
    ].join('#')
  end

  def avatar_url(size = nil)
    return nil if avatar.blank?
    url = "https://cdn.discordapp.com/avatars/#{model.discord_id}/#{model.avatar}.png"
    url += "?size=#{size}" if size
    url
  end

  def avatar_tag(size = nil)
    return nil if avatar.blank?
    h.image_tag avatar_url(size), class: 'avatar'
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
