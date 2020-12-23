class Api::V1::TournamentEventsController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per

  def index
    tournament_events = apply_scopes(TournamentEvent).all
    render json: tournament_events
  end

end
