class AdminUserDecorator < BaseDecorator

  def discord_user_admin_link(size: nil)
    model.discord_user.decorate.admin_link(size: size)
  end

  def full_name(size: nil)
    model.discord_user.decorate.full_name(size: size)
  end

end
