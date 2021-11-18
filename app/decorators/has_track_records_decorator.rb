module HasTrackRecordsDecorator
  def points_count(icon_size = 32, options = {})
    options[:height] = icon_size
    is_online = options.delete(:is_online)
    year = options.delete(:year)
    value = options.delete(:value) || points(is_online: is_online, year: year)
    emoji = is_online ? RetropenBot::EMOJI_POINTS_ONLINE : RetropenBot::EMOJI_POINTS_OFFLINE
    delimiter = options.delete(:delimiter) || ''
    [
      h.image_tag(
        "https://cdn.discordapp.com/emojis/#{emoji}.png",
        options
      ),
      h.content_tag(:span, h.number_with_delimiter(value))
    ].join(delimiter).html_safe
  end

  def best_reward_badge(opt = {})
    options = opt.clone
    best_reward_condition(is_online: options.delete(:is_online))&.decorate&.reward_badge(options)
  end
end
