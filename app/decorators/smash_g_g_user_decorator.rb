class SmashGGUserDecorator < BaseDecorator

  def prefixed_gamer_tag
    [
      model.prefix,
      model.gamer_tag
    ].compact.join(' | ')
  end

  def full_name(options = {})
    [
      avatar_tag(options),
      prefixed_gamer_tag
    ].join('&nbsp;').html_safe
  end

  def avatar_tag(max_width: nil, max_height: nil)
    return nil if avatar_url.blank?
    h.image_tag_with_max_size avatar_url,
                              max_width: max_width,
                              max_height: max_height,
                              class: 'avatar'
  end

  def banner_tag(max_width: nil, max_height: nil)
    return nil if banner_url.blank?
    h.image_tag_with_max_size banner_url,
                              max_width: max_width,
                              max_height: max_height,
                              class: 'banner'
  end

  def smash_gg_link
    return nil if model.slug.blank?
    h.link_to "https://smash.gg/#{model.slug}", target: '_blank' do
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

end
