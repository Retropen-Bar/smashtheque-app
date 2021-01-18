class YouTubeChannelDecorator < BaseDecorator

  def channel_url
    url
  end

  def channel_link(with_icon: false)
    txt = model.name
    if with_icon
      txt = '<i class="fab fa-youtube fa-lg"></i> ' + txt
    end
    h.link_to txt.html_safe, channel_url, target: '_blank'
  end

end
