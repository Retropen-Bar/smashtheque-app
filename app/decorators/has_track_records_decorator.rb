module HasTrackRecordsDecorator
  def points_count(icon_size = 32, options = {})
    options[:height] = icon_size
    is_online = options.delete(:is_online)
    year = options.delete(:year)
    value = options.delete(:value) || points(is_online: is_online, year: year)
    emoji = is_online ? RetropenBot::EMOJI_POINTS_ONLINE : RetropenBot::EMOJI_POINTS_OFFLINE
    [
      h.image_tag(
        "https://cdn.discordapp.com/emojis/#{emoji}.png",
        options
      ),
      h.number_with_delimiter(value)
    ].join('&nbsp;').html_safe
  end

  def best_rewards_badges(options = {})
    best_rewards(is_online: options.delete(:is_online)).map do |reward|
      reward.decorate.badge(options.clone)
    end
  end

  def unique_rewards_badges(options = {})
    unique_rewards(is_online: options.delete(:is_online)).ordered_by_level.decorate.map do |reward|
      reward.badge(options.clone)
    end
  end
end
