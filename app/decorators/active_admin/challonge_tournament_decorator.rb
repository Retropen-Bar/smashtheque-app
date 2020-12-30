class ActiveAdmin::ChallongeTournamentDecorator < ChallongeTournamentDecorator
  include ActiveAdmin::BaseDecorator

  decorates :challonge_tournament

  def admin_link(options = {})
    super({label: name_with_icon(size: 16)}.merge(options))
  end

  def tournament_event_admin_link(options = {})
    tournament_event&.admin_decorate&.admin_link(options)
  end

end
