class SmashggUserDecorator < BaseDecorator
  def prefixed_gamer_tag
    [
      model.prefix,
      model.gamer_tag
    ].compact.join(' | ')
  end

  def avatar_and_name(options = {})
    [
      any_image_tag(**options),
      prefixed_gamer_tag || slug
    ].join('&nbsp;').html_safe
  end

  def any_image_url
    avatar_url.presence || SmashggEvent::ICON_URL
  end

  def any_image_tag(size: 32)
    h.image_tag 's.gif',
                class: 'avatar',
                style: [
                  "background-image: url(\"#{any_image_url}\")",
                  'background-size: cover',
                  "width: #{size}px",
                  "height: #{size}px"
                ].join(';')
  end

  def banner_tag(max_width: nil, max_height: nil)
    return nil if banner_url.blank?

    h.image_tag_with_max_size banner_url,
                              max_width: max_width,
                              max_height: max_height,
                              class: 'banner'
  end

  def smashgg_badge(options = {})
    return nil if model.slug.blank?

    h.link_to smashgg_url, class: 'account-badge', target: '_blank', rel: :noopener do
      (
        h.image_tag SmashggEvent::ICON_URL, height: 24, class: 'logo'
      ) + ' ' + (
        avatar_and_name(**options)
      )
    end
  end

  def smashgg_badge_logo_only(options = {})
    return nil if model.slug.blank?

    h.link_to smashgg_url, target: '_blank', rel: :noopener do
      (
        h.content_tag :span, "Profil start.gg de #{prefixed_gamer_tag || slug}", class: 'sr-only'
      ) + ' ' + (
        h.svg_icon_tag(:smashgg)
      )
    end
  end

  def smashgg_link
    return nil if model.slug.blank?

    h.link_to smashgg_url, target: '_blank', rel: :noopener do

      (
        h.image_tag SmashggEvent::ICON_URL, height: 16, class: 'logo'
      ) + ' ' + (
        h.tag.span model.slug
      )
    end
  end

  def discord_link
    return nil if model.discord_discriminated_username.blank?

    h.link_to '#' do
      (
        h.fab_icon_tag :discord
      ) + ' ' + (
        h.tag.span model.discord_discriminated_username
      )
    end
  end
end
