class ActiveAdmin::AdminUserDecorator < AdminUserDecorator
  include ActiveAdmin::BaseDecorator

  decorates :admin_user

  def discord_user_admin_link(size: nil)
    model.discord_user&.admin_decorate&.admin_link(size: size)
  end

  # compatibility
  def admin_link
    discord_user_admin_link(size: 32)
  end

  def full_name(size: nil)
    model.discord_user.admin_decorate.full_name(size: size)
  end

  LEVEL_COLORS = {
    Ability::LEVEL_HELP => :rose,
    Ability::LEVEL_ADMIN => :blue,
    root: :green
  }

  def level_status
    key = model.is_root? ? :root : model.level
    arbre do
      status_tag AdminUser.human_attribute_name("level.#{key}"), class: LEVEL_COLORS[key]
    end
  end

end
