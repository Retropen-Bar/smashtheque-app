class ActiveAdmin::UserDecorator < UserDecorator
  include ActiveAdmin::BaseDecorator

  decorates :user

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

  ADMIN_LEVEL_COLORS = {
    Ability::ADMIN_LEVEL_HELP => :rose,
    Ability::ADMIN_LEVEL_ADMIN => :blue,
    root: :green
  }

  def admin_level_status
    key = model.is_root? ? :root : model.admin_level
    arbre do
      status_tag User.human_attribute_name("admin_level.#{key}"), class: ADMIN_LEVEL_COLORS[key]
    end
  end

end
