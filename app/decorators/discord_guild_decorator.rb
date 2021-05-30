class DiscordGuildDecorator < BaseDecorator
  def icon_and_name_or_id(size: nil)
    if model.is_known?
      icon_and_name(size: size)
    else
      "##{model.discord_id}"
    end
  end

  def icon_and_name(size: nil)
    [
      icon_image_tag(size),
      model.name
    ].join('&nbsp;').html_safe
  end

  def name_or_id
    if model.is_known?
      model.name
    else
      "##{model.discord_id}"
    end
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

    h.image_tag_with_max_size icon_image_url,
                              max_width: size,
                              max_height: size,
                              class: 'avatar'
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

  def link
    h.link_to icon_and_name(size: 32), model.invitation_url, target: '_blank', class: 'btn btn-outline-primary'
  end

  def related_characters
    model.relateds.select do |related|
      related.is_a?(Character)
    end.sort_by do |character|
      character.name.downcase
    end
  end
end
