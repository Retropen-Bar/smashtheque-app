class UserDecorator < BaseDecorator

  def name
    model.discord_user&.username
  end

  def avatar_tag(size)
    if model.discord_user && !model.discord_user.avatar.blank?
      model.discord_user.decorate.avatar_tag(size)
    else
      default_avatar(size)
    end
  end

  def default_avatar(size)
    h.image_tag 'default-avatar.jpg', width: size, class: :avatar
  end

end
