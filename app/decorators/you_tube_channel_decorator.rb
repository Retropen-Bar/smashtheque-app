class YouTubeChannelDecorator < BaseDecorator
  def channel_url
    url
  end

  def channel_link(with_icon: false)
    txt = model.name
    txt = "<i class='fab fa-youtube fa-lg'></i> #{txt}" if with_icon
    h.link_to txt.html_safe, channel_url, target: '_blank', rel: :noopener
  end
end
