class ActiveAdmin::ChallongeTournamentDecorator < ChallongeTournamentDecorator
  include ActiveAdmin::BaseDecorator

  decorates :challonge_tournament

  def tournament_event_admin_link(options = {})
    tournament_event&.admin_decorate&.admin_link(options)
  end

end
