module ActiveAdmin::AdminUsersHelper

  def admin_user_level_select_collection
    Ability::LEVELS.map do |v|
      [
        AdminUser.human_attribute_name("level.#{v}"),
        v
      ]
    end
  end

end
