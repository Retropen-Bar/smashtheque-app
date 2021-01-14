module ActiveAdmin::UsersHelper

  def user_admin_level_select_collection
    Ability::ADMIN_LEVELS.map do |v|
      [
        User.human_attribute_name("admin_level.#{v}"),
        v
      ]
    end
  end

end
