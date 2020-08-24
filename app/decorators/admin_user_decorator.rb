class AdminUserDecorator < BaseDecorator

  def discord_user_admin_link(size: nil)
    model.discord_user.decorate.admin_link(size: size)
  end

  # compatibility
  def admin_link
    discord_user_admin_link(size: 32)
  end

  def full_name(size: nil)
    model.discord_user.decorate.full_name(size: size)
  end

end
