class ActiveAdmin::UserDecorator < UserDecorator
  include ActiveAdmin::BaseDecorator

  decorates :user

  def discord_user_admin_link(options = {})
    model.discord_user&.admin_decorate&.admin_link(options)
  end

  def player_admin_link(options = {})
    model.player&.admin_decorate&.admin_link(options)
  end

  # compatibility
  def admin_link(options = {})
    super({
      label: full_name(size: 32)
    }.merge(options))
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

  def administrated_teams_admin_links(options = {})
    model.administrated_teams.map do |team|
      team.admin_decorate.admin_link(options)
    end
  end

  def administrated_recurring_tournaments_admin_links(options = {})
    model.administrated_recurring_tournaments.map do |recurring_tournament|
      recurring_tournament.admin_decorate.admin_link(options)
    end
  end

end
