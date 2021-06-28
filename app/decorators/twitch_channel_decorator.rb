class TwitchChannelDecorator < BaseDecorator
  def channel_url
    "https://www.twitch.tv/#{model.slug}"
  end

  def channel_link(with_icon: false)
    txt = model.slug
    txt = "<i class='fab fa-twitch fa-lg'></i> #{txt}" if with_icon
    h.link_to txt.html_safe, channel_url, target: '_blank', rel: :noopener
  end

  def related_link(options = {})
    related&.decorate&.link(options)
  end

  def profile_image_tag(options = {})
    return nil if profile_image_url.blank?

    h.image_tag_with_max_size profile_image_url, options
  end

  def language_icon_tag(options = {})
    if is_french?
      h.image_tag 'flag-fr.svg', options
    else
      h.fas_icon_tag :globe, options
    end
  end
end
