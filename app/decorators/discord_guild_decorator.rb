class DiscordGuildDecorator < BaseDecorator

  def full_name_or_id(size: nil)
    if model.is_known?
      full_name(size: size)
    else
      "##{model.discord_id}"
    end
  end

  def full_name(size: nil)
    [
      icon_image_tag(size),
      model.name
    ].join('&nbsp;').html_safe
  end

  def invitation_link
    h.link_to model.invitation_url, model.invitation_url, target: '_blank'
  end

  def icon_image_url(size = nil)
    return nil if model.icon.blank?
    url = "https://cdn.discordapp.com/icons/#{model.discord_id}/#{model.icon}.png"
    url += "?size=#{size}" if size
    url
  end

  def icon_image_tag(size = nil)
    return nil if model.icon.blank?
    h.image_tag icon_image_url(size), class: 'avatar'
  end

  def splash_image_url(size = nil)
    return nil if model.splash.blank?
    url = "https://cdn.discordapp.com/splashes/#{model.discord_id}/#{model.splash}.png"
    url += "?size=#{size}" if size
    url
  end

  def splash_image_tag(size = nil)
    return nil if model.splash.blank?
    h.image_tag splash_image_url(size)
  end

end
