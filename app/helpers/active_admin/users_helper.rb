module ActiveAdmin::UsersHelper

  def user_level_select_collection
    Ability::LEVELS.map do |v|
      [
        User.human_attribute_name("level.#{v}"),
        v
      ]
    end
  end

end
