class RecurringTournamentsController < PublicController

  has_scope :by_level_in, type: :array
  has_scope :by_size_geq
  has_scope :by_size_leq

  def index
    respond_to do |format|
      format.html {
        redirect_to planning_path
      }
      format.json {
        start = Date.parse(params[:start])
        render json: apply_scopes(RecurringTournament).all.decorate.map { |rc|
          rc.as_event(week_start: start).merge(
            url: recurring_tournament_path(rc)
          )
        }
      }
    end
  end

  def show
    @recurring_tournament = RecurringTournament.find(params[:id]).decorate
  end

end
