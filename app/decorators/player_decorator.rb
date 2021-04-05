class PlayerDecorator < BaseDecorator

  def autocomplete_name
    model.name
  end

  def listing_name
    model.name
  end

  def name_with_teams
    (teams.map(&:short_name) + [name]).join('&nbsp;|&nbsp;')
  end

  def avatar_tag(size)
    # option 1: DiscordUser
    if user && user.discord_user && !user.discord_user.avatar.blank?
      return user.discord_user.decorate.avatar_tag(size)
    end
    # option 2: SmashggUser
    smashgg_users.each do |smashgg_user|
      unless smashgg_user.avatar_url.blank?
        return smashgg_user.decorate.any_image_tag(size: size)
      end
    end
    # default
    default_avatar(size)
  end

  def name_with_avatar(size: nil, with_teams: false)
    txt = [name]
    if with_teams
      txt = teams.map(&:short_name) + txt
    end
    [
      avatar_tag(size),
      txt.join('&nbsp;|&nbsp;')
    ].join('&nbsp;').html_safe
  end

  def default_avatar(size)
    h.image_tag 'default-avatar.jpg', width: size, class: :avatar
  end

  def map_popup
    h.content_tag :div, class: 'map-popup-player' do
      h.link_to model, class: 'player' do
        [
          name_with_avatar(size: 64),
          (
            h.content_tag :div, class: 'player-characters' do
              model.characters.map do |character|
                character.decorate.emoji_image_tag(max_height: 32)
              end.join('&nbsp;').html_safe
            end
          )
        ].join('<br/>').html_safe
      end
    end
  end

  def ban_status
    if model.is_banned?
      h.content_tag :span,
                    'oui',
                    class: 'status_tag yes',
                    title: model.ban_details,
                    data: { tooltip: {} }
    else
      arbre do
        status_tag :no
      end
    end
  end

  def icon_class
    :user
  end

  def points_count(icon_size = 32, options = {})
    options[:height] = icon_size
    value = options.delete(:value) || points
    [
      h.image_tag(
        "https://cdn.discordapp.com/emojis/#{RetropenBot::EMOJI_POINTS}.png",
        options
      ),
      h.number_with_delimiter(value)
    ].join('&nbsp;').html_safe
  end

  def link(options = {})
    avatar_size = options.delete(:avatar_size) || 32
    if model.is_legit?
      super({label: name_with_avatar(size: avatar_size)}.merge(options))
    else
      [
        default_avatar(avatar_size),
        '-'
      ].join('&nbsp;').html_safe
    end
  end

  def name_and_old_names(with_teams: false)
    result = with_teams ? name_with_teams : name
    if old_names.any?
      result += " (aka #{old_names.reverse.join(', ')})"
    end
    result
  end

  def name_and_old_names_and_main(with_teams: false)
    result = name_and_old_names(with_teams: with_teams)
    characters.first(5).each do |character|
      result += ' ' + character.decorate.emoji_image_tag(max_height: 20)
    end
    result.html_safe
  end

  def as_autocomplete_result
    h.content_tag :div, class: :player do
      h.content_tag :div, class: :name do
        name_and_old_names_and_main(with_teams: true)
      end
    end
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

  def discord_badge(options = {})
    discord_user&.decorate&.discord_badge(options)
  end

end
