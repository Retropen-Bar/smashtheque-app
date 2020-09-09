class TwitchChannelDecorator < BaseDecorator

  def channel_url
    "https://www.twitch.tv/#{model.username}"
  end

  def channel_link(with_icon: false)
    txt = model.username
    if with_icon
      txt = '<i class="fab fa-twitch fa-lg"></i> ' + txt
    end
    h.link_to txt.html_safe, channel_url, target: '_blank'
  end

end
