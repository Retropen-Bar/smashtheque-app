class DuoDecorator < BaseDecorator

  def name_with_player_names
    "#{name} : #{player1_name} & #{player2_name}"
  end

  def avatars_tag(size)
    h.content_tag :div, class: 'avatars' do
      (
        player1&.decorate&.avatar_tag(size)
      ) + (
        player2&.decorate&.avatar_tag(size)
      )
    end
  end

  def name_with_avatars(size: nil)
    [
      avatars_tag(size),
      name
    ].join('&nbsp;').html_safe
  end

  def points_count(icon_size = 32, options = {})
    options[:height] = icon_size
    value = options.delete(:value) || points
    [
      h.image_tag(
        "https://cdn.discordapp.com/emojis/#{RetropenBot::EMOJI_POINTS_ONLINE}.png",
        options
      ),
      h.number_with_delimiter(value)
    ].join('&nbsp;').html_safe
  end

  def link(options = {})
    avatar_size = options.delete(:avatar_size) || 32
    super({label: name_with_avatars(size: avatar_size)}.merge(options))
  end

  def best_rewards_badges(options = {})
    best_rewards.map do |reward|
      reward.decorate.badge(options.clone)
    end
  end

  def unique_rewards_badges(options = {})
    unique_rewards.ordered_by_level.decorate.map do |reward|
      reward.badge(options.clone)
    end
  end

  def icon_class
    'user-friends'
  end

  def as_autocomplete_result
    h.content_tag :div, class: :duo do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

end
