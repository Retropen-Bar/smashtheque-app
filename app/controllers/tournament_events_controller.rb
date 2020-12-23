class TournamentEventsController < PublicController

  has_scope :page, default: 1
  has_scope :per

  def index
    @tournament_events = apply_scopes(TournamentEvent.order("date")).all
  end

  def show
    @tournament_event = TournamentEvent.find(params[:id]).decorate
  end

end
