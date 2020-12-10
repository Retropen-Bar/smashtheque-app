class RecurringTournamentsController < PublicController

  before_action :set_recurring_tournament, only: %w(show modal)
  decorates_assigned :recurring_tournament

  has_scope :by_level_in, type: :array
  has_scope :by_size_geq
  has_scope :by_size_leq

  def index
    respond_to do |format|
      format.html {
        redirect_to planning_path
      }
      format.json {
        start = Date.parse(params[:startStr])
        render json: apply_scopes(RecurringTournament).all.decorate.map { |rc|
          rc.as_event(week_start: start).merge(
            url: recurring_tournament_path(rc)
          )
        }
      }
    end
  end

  def show
  end

  def modal
    render :modal, layout: false
  end

  private

  def set_recurring_tournament
    @recurring_tournament = RecurringTournament.find(params[:id])
  end

end
