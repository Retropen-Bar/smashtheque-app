class SmashggUserDecorator < BaseDecorator

  def prefixed_gamer_tag
    [
      model.prefix,
      model.gamer_tag
    ].compact.join(' | ')
  end

  def full_name(options = {})
    [
      any_image_tag(options),
      prefixed_gamer_tag || slug
    ].join('&nbsp;').html_safe
  end

  def any_image_url
    avatar_url.presence || 'https://smash.gg/images/gg-app-icon.png'
  end

  def any_image_tag(size: 32)
    h.image_tag 's.gif',
                class: 'avatar',
                style: [
                  "background-image: url(\"#{any_image_url}\")",
                  "background-size: cover",
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

  def smashgg_link
    return nil if model.slug.blank?
    h.link_to smashgg_url, target: '_blank' do
      (
        h.image_tag 'https://smash.gg/images/gg-app-icon.png', height: 16, class: 'logo'
      ) + ' ' + (
        h.content_tag :span, model.slug
      )
    end
  end

  def twitch_link
    return nil if model.twitch_username.blank?
    h.link_to "https://www.twitch.tv/#{model.twitch_username}", target: '_blank' do
      (
        h.content_tag :i, '', class: 'fab fa-twitch'
      ) + ' ' + (
        h.content_tag :span, model.twitch_username
      )
    end
  end

  def twitter_link
    return nil if model.twitter_username.blank?
    h.link_to "https://twitter.com/#{model.twitter_username}", target: '_blank' do
      (
        h.content_tag :i, '', class: 'fab fa-twitter-square'
      ) + ' ' + (
        h.content_tag :span, model.twitter_username
      )
    end
  end

  def discord_link
    return nil if model.discord_discriminated_username.blank?
    h.link_to '#' do
      (
        h.fab_icon_tag :discord
      ) + ' ' + (
        h.content_tag :span, model.discord_discriminated_username
      )
    end
  end

end
