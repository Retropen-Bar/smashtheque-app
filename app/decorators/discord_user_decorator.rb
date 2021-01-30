class DiscordUserDecorator < BaseDecorator

  def full_name_or_id(size: nil)
    if model.is_known?
      full_name(size: size)
    else
      "##{model.discord_id}"
    end
  end

  def full_name(size: nil)
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
    @@default_avatar_url ||= h.image_url('default-avatar.jpg')
  end

  def avatar_tag(size = nil)
    return nil if avatar.blank?
    h.image_tag 's.gif',
                class: 'avatar',
                style: [
                  "background-image: url(\"#{avatar_url}\"), url(\"#{default_avatar_url}\")",
                  "background-size: cover",
                  "width: #{size}px",
                  "height: #{size}px"
                ].join(';')
  end

  def player_link(options = {})
    model.player.decorate.link(options)
  end

  def link(options = {})
    h.content_tag :div, full_name_or_id(size: 32), options
  end

end
