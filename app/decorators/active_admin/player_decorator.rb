class ActiveAdmin::PlayerDecorator < PlayerDecorator
  include ActiveAdmin::BaseDecorator

  decorates :player

  def characters_admin_links
    model.characters.map do |character|
      character.admin_decorate.admin_emoji_link
    end
  end

  def locations_admin_links
    model.locations.map do |location|
      location.admin_decorate.admin_link
    end
  end

  def teams_admin_links
    model.teams.map do |team|
      team.admin_decorate.admin_link
    end
  end

  def creator_admin_link(options = {})
    model.creator.admin_decorate.admin_link options
  end

  def discord_user_admin_link(options = {})
    model.discord_user&.admin_decorate&.admin_link options
  end

end
