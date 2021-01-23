module ActiveAdmin::DuoTournamentEventsHelper

  def duo_tournament_event_recurring_tournament_select_collection
    RecurringTournament.order(:name).map do |recurring_tournament|
      [
        recurring_tournament.name,
        recurring_tournament.id
      ]
    end
  end

end
