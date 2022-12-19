class DiscordUserDecorator < BaseDecorator
  # warning: this method is an ActiveAdmin convention
  def full_name
    discriminated_username
  end

  def avatar_and_name_or_id(size: nil)
    if model.is_known?
      avatar_and_name(size: size)
    else
      "##{model.discord_id}"
    end
  end

  def avatar_and_name(size: nil)
    [
      avatar_tag(size),
      discriminated_username
    ].join('&nbsp;').html_safe
  end

  def avatar_url(size = nil)
    return nil if avatar.blank?

    extension = model.avatar.start_with?('a_') ? :gif : :png
    url = "https://cdn.discordapp.com/avatars/#{model.discord_id}/#{model.avatar}.#{extension}"
    url += "?size=#{size}" if size
    url
  end

  def default_avatar_url
    @@default_avatar_url ||= h.image_url('default-avatar.svg')
  end

  def avatar_tag(size = 32)
    return nil if avatar.blank?

    h.image_tag 's.gif',
                class: 'avatar',
                style: [
                  "background-image: url(\"#{avatar_url}\"), url(\"#{default_avatar_url}\")",
                  'background-size: cover',
                  "width: #{size}px",
                  "height: #{size}px"
                ].join(';')
  end

  def player_link(options = {})
    model.player.decorate.link(options)
  end

  def discord_url
    return nil if model.discord_id.blank?

    "discord://-/users/#{discord_id}"
  end

  def link(options = {})
    h.link_to avatar_and_name_or_id(size: 32),
              discord_url,
              { target: '_blank', rel: :noopener }.merge(options)
  end

  def discord_link(options = {})
    return nil if model.discord_id.blank?

    txt = options.delete(:label) || [
      h.fab_icon_tag(:discord),
      discriminated_username
    ].join('&nbsp;').html_safe

    h.link_to txt,
              discord_url,
              { target: '_blank', rel: :noopener }.merge(options)
  end

  def discord_badge(options = {})
    h.link_to discord_url, class: 'account-badge', target: '_blank', rel: :noopener do
      [
        h.fab_icon_tag(:discord),
        avatar_and_name(size: options.delete(:size) || 32)
      ].join('&nbsp;').html_safe
    end
  end

  def discord_badge_logo_only
    h.link_to discord_url, target: '_blank', rel: :noopener do
      [
        h.content_tag(:span, "Compte start.gg de #{discriminated_username}", class: 'sr-only'),
        h.svg_icon_tag(:discord)
      ].join('').html_safe
    end
  end
end
