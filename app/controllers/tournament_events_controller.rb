class TournamentEventsController < PublicController

  decorates_assigned :tournament_event

  has_scope :page, default: 1
  has_scope :per

  def index
    @tournament_events = apply_scopes(TournamentEvent.order(date: :desc)).all
  end

  def show
    @tournament_event = TournamentEvent.find(params[:id])
  end

end
