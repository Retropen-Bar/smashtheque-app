class ActiveAdmin::ChallongeTournamentDecorator < ChallongeTournamentDecorator
  include ActiveAdmin::BaseDecorator

  decorates :challonge_tournament

  def start_at_date
    h.l model.start_at.to_date, format: :default
  end

  def admin_link(options = {})
    super({label: name_with_icon(size: 16)}.merge(options))
  end

  def tournament_event_admin_link(options = {})
    tournament_event&.admin_decorate&.admin_link(options)
  end

  def duo_tournament_event_admin_link(options = {})
    duo_tournament_event&.admin_decorate&.admin_link(options)
  end

  def any_tournament_event_admin_link(options = {})
   any_tournament_event&.admin_decorate&.admin_link(options)
  end

  def create_tournament_event_admin_path
    attributes = {
      name: name,
      date: start_at,
      participants_count: participants_count,
      bracket_url: challonge_url,
      bracket_gid: model.to_global_id.to_s
    }
    new_admin_tournament_event_path(tournament_event: attributes)
  end

  def create_duo_tournament_event_admin_path
    attributes = {
      name: name,
      date: start_at,
      participants_count: participants_count,
      bracket_url: challonge_url,
      bracket_gid: model.to_global_id.to_s
    }
    new_admin_duo_tournament_event_path(duo_tournament_event: attributes)
  end

end
