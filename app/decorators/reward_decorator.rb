class RewardDecorator < BaseDecorator

  def emoji_image_url
    "https://cdn.discordapp.com/emojis/#{model.emoji}.png"
  end

  def badge(options = {})
    return nil if model.emoji.blank?

    classes = [
      'reward-badge',
      options.delete(:class)
    ].reject(&:blank?).join(' ')

    count = options.delete(:count)

    h.content_tag :div, class: classes do
      (
        h.image_tag emoji_image_url
      ) + (
        if count.nil?
          ''
        else
          h.content_tag :div, count, class: 'badge-counter'
        end
      )
    end
  end

  def all_badge_sizes(options = {})
    [
      badge({class: 'reward-badge-128'}.merge(options)),
      badge(options.clone),
      badge({class: 'reward-badge-32'}.merge(options))
    ].join(' ').html_safe
  end

  def reward_conditions_count
    reward_conditions.count
  end

  def player_reward_conditions_count
    player_reward_conditions.count
  end

  def players_count
    players.count
  end

  def level
    [level1, level2].join('.')
  end

end
