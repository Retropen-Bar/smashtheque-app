class UserDecorator < BaseDecorator

  def avatar_tag(size)
    if discord_user && !discord_user.avatar.blank?
      discord_user.decorate.avatar_tag(size)
    else
      default_avatar(size)
    end
  end

  def default_avatar(size)
    h.image_tag 'default-avatar.jpg', width: size, class: :avatar
  end

  def avatar_and_name(size: nil)
    [
      avatar_tag(size),
      name
    ].join('&nbsp;').html_safe
  end

  def player_link(options = {})
    model.player.decorate.link(options)
  end

  def link(options = {})
    h.content_tag :div, avatar_and_name(size: 32), options
  end

  def created_players_count
    created_players.count
  end

  def coaching_link(options = {})
    return nil unless is_coach? || coaching_url.blank?
    h.link_to (options[:label] || 'Voir la page'), coaching_url, {
      target: '_blank'
    }.merge(options)
  end

  def discord_badge(options = {})
    discord_user&.decorate&.discord_badge(options)
  end

end
