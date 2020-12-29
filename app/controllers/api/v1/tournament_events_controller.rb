class Api::V1::TournamentEventsController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per

  def index
    tournament_events = apply_scopes(TournamentEvent).all
    render json: tournament_events
  end

  def show
    tournament_event = TournamentEvent.find(params[:id])
    render json: tournament_event
  end

  def create
    tournament_event = TournamentEvent.new(tournament_event_params)
    # auto-complete with data from bracket API
    tournament_event.complete_with_bracket

    if tournament_event.save
      render json: tournament_event, status: :created
    else
      logger.debug "Record errors: #{tournament_event.errors.full_messages}"
      render_errors tournament_event.errors, :unprocessable_entity
    end
  end

  private

  def tournament_event_params
    params.require(:tournament_event).permit(%i(
      recurring_tournament_id smashgg_event_id
      name date participants_count bracket_url is_complete
      top1_player_id top2_player_id top3_player_id top4_player_id
      top5a_player_id top5b_player_id top7a_player_id top7b_player_id
      graph graph_url
    ))
  end

end
