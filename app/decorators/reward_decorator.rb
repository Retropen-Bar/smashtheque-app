class RewardDecorator < BaseDecorator
  def image_image_url
    return nil unless model.image.attached?

    model.image.service_url
  end

  def image_image_tag(options = {})
    return nil unless model.image.attached?

    h.image_tag_with_max_size image_image_url, options.merge(class: 'avatar')
  end

  def badge_image_url
    image_image_url
  end

  def badge(options = {})
    return nil unless model.image.attached?

    classes = [
      'reward-badge',
      options.delete(:class)
    ].reject(&:blank?).join(' ')

    count = options.delete(:count)

    wrapper_options = { class: classes }
    if (tooltip = options[:tooltip] || badge_tooltip)
      wrapper_options[:title] = tooltip
      wrapper_options[:data] = { tooltip: {} }
    end

    h.tag.div(**wrapper_options) do
      (
        h.image_tag badge_image_url, class: 'img-fluid'
      ) + (
        if count.nil?
          ''
        else
          h.tag.div count, class: 'badge-counter'
        end
      )
    end
  end

  def all_badge_sizes(options = {})
    [
      badge({ class: 'reward-badge-128' }.merge(options)),
      badge(options.clone),
      badge({ class: 'reward-badge-32' }.merge(options))
    ].join(' ').html_safe
  end

  def reward_conditions_count
    reward_conditions.count
  end

  def met_reward_conditions_count
    met_reward_conditions.count
  end

  def players_count
    players.count
  end

  def duos_count
    duos.count
  end

  def awardeds_count
    awardeds.count
  end

  def level
    [level1, level2].join('.')
  end

  def category_name
    return nil if category.blank?

    Reward.human_attribute_name("category.#{category}")
  end

  def name
    [category_name, level].join(' ')
  end

  def badge_tooltip
    reward_conditions.first&.decorate&.badge_tooltip
  end
end
