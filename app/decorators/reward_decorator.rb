class RewardDecorator < BaseDecorator

  def image_data_url
    return nil if model.image.blank?
    [
      'data:image/svg+xml;base64',
      Base64.strict_encode64(model.image)
    ].join(',')
  end

  def image_tag(options = {})
    return nil if model.image.blank?
    h.image_tag_with_max_size image_data_url, options
  end

  def badge(options = {})
    return nil if model.image.blank?

    classes = [
      'reward-badge-container',
      options.delete(:class)
    ].reject(&:blank?).join(' ')

    count = options.delete(:count)

    h.content_tag :div, class: classes do
      (
        h.content_tag :div, class: 'reward-badge', style: model.style do
          h.content_tag :div, class: 'reward-badge-circle' do
            image_tag(options)
          end
        end
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

  def formatted_style
    h.content_tag :div, model.style, class: 'free-text'
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
