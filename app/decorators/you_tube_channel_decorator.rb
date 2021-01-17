class YouTubeChannelDecorator < BaseDecorator

  def channel_link(with_icon: false)
    txt = model.name
    if with_icon
      txt = '<i class="fab fa-youtube fa-lg"></i> ' + txt
    end
    h.link_to txt.html_safe, url, target: '_blank'
  end

end
