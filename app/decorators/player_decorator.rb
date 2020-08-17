class PlayerDecorator < BaseDecorator

  def icon_class
    :user
  end

  def characters_links
    model.characters.decorate.map(&:admin_link)
  end

  def city_link
    model.city&.decorate&.admin_link
  end

  def team_link
    model.team&.decorate&.admin_link
  end

end
