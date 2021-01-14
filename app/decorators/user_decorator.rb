class UserDecorator < BaseDecorator

  def avatar_tag(size)
    discord_users.each do |discord_user|
      unless discord_user.avatar.blank?
        return discord_user.decorate.avatar_tag(size)
      end
    end
    default_avatar(size)
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

end
