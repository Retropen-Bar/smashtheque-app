class RecurringTournamentsController < PublicController

  before_action :set_recurring_tournament, only: %w(show modal)
  decorates_assigned :recurring_tournament

  has_scope :by_level_in, type: :array
  has_scope :by_size_geq
  has_scope :by_size_leq
  has_scope :page, default: 1
  has_scope :per

  def index
    respond_to do |format|
      format.html {
        index_html
      }
      format.json {
        index_json
      }
    end
  end

  def index_html
    @recurring_tournaments = apply_scopes(RecurringTournament.order("lower(name)")).all
  end

  def index_json
    start = Date.parse(params[:startStr])
    render json: apply_scopes(
      RecurringTournament.recurring.not_archived
    ).all.decorate.map { |rc|
      rc.as_event(week_start: start).merge(
        url: recurring_tournament_path(rc)
      )
    }
  end

  def show
    @tournament_events = @recurring_tournament.tournament_events.order(date: :desc)
  end

  def modal
    render :modal, layout: false
  end

  private

  def set_recurring_tournament
    @recurring_tournament = RecurringTournament.find(params[:id])
  end

end
