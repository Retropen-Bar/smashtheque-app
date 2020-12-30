class LinkTournamentEventsToPolymorphicBracket < ActiveRecord::Migration[6.0]
  def change
    add_reference :tournament_events, :bracket, polymorphic: true
    TournamentEvent.where.not(smashgg_event_id: nil)
                   .update_all(bracket_type: :SmashggEvent)
    TournamentEvent.where.not(smashgg_event_id: nil)
                   .update_all("bracket_id = smashgg_event_id")
    TournamentEvent.where.not(challonge_tournament_id: nil)
                   .update_all(bracket_type: :ChallongeTournament)
    TournamentEvent.where.not(challonge_tournament_id: nil)
                   .update_all("bracket_id = challonge_tournament_id")
    remove_column :tournament_events, :smashgg_event_id
    remove_column :tournament_events, :challonge_tournament_id
  end
end
