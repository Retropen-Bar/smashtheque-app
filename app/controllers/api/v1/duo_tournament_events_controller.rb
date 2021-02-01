class Api::V1::DuoTournamentEventsController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per

  def index
    duo_tournament_events = apply_scopes(DuoTournamentEvent).all
    render json: duo_tournament_events
  end

  def show
    duo_tournament_event = DuoTournamentEvent.find(params[:id])
    render json: duo_tournament_event
  end

  def create
    duo_tournament_event = DuoTournamentEvent.new(duo_tournament_event_params)
    # auto-complete with data from bracket API
    duo_tournament_event.complete_with_bracket

    if existing = DuoTournamentEvent.where(bracket_id: duo_tournament_event.bracket_id).first
      # this tournament is already known:
      # update graph if available, otherwise let the error happen
      unless duo_tournament_event_params[:graph_url].blank?
        existing.graph_url = duo_tournament_event_params[:graph_url]
        if existing.save
          render json: existing, status: :ok
        else
          render_errors existing.errors, :unprocessable_entity
        end
        return
      end
    end

    if duo_tournament_event.save
      render json: duo_tournament_event, status: :created
    else
      logger.debug "Record errors: #{duo_tournament_event.errors.full_messages}"
      render_errors duo_tournament_event.errors, :unprocessable_entity
    end
  end

  private

  def duo_tournament_event_params
    params.require(:duo_tournament_event).permit(%i(
      recurring_tournament_id smashgg_event_id
      name date participants_count bracket_url is_complete
      top1_duo_id top2_duo_id top3_duo_id top4_duo_id
      top5a_duo_id top5b_duo_id top7a_duo_id top7b_duo_id
      graph graph_url
    ))
  end

end
