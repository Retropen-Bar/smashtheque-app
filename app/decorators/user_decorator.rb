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

  def full_name(size: nil)
    [
      avatar_tag(size),
      name
    ].join('&nbsp;').html_safe
  end

  def player_link(options = {})
    model.player.decorate.link(options)
  end

  def link(options = {})
    h.content_tag :div, full_name(size: 32), options
  end

end
