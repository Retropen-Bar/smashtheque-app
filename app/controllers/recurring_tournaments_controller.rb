class RecurringTournamentsController < PublicController

  def index
    respond_to do |format|
      format.html {
        redirect_to planning_path
      }
      format.json {
        start = Date.parse(params[:start])
        render json: RecurringTournament.all.decorate.map { |rc|
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
