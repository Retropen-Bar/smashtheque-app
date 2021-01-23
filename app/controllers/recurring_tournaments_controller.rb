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
      format.ics {
        index_ical
      }
    end
  end

  def index_html
    @recurring_tournaments = apply_scopes(
      RecurringTournament.order("lower(name)")
    ).all
  end

  def index_json
    start = params[:startStr] ? Date.parse(params[:startStr]) : Time.now
    render json: apply_scopes(
      RecurringTournament.recurring.not_archived
    ).all.decorate.map { |rc|
      rc.as_event(week_start: start).merge(
        url: recurring_tournament_path(rc)
      )
    }
  end

  def index_ical
    cal = Icalendar::Calendar.new
    cal.x_wr_calname = 'Planning online à 7 jours'

    apply_scopes(
      RecurringTournament.recurring.not_archived
    ).per(1000).all.decorate.each do |recurring_tournament|
      event = recurring_tournament.as_ical_event
      event.url = polymorphic_url recurring_tournament
      event.description += "\nPlus d'infos : #{event.url}"
      cal.add_event event
    end

    cal.publish
    render plain: cal.to_ical
  end

  def show
    @tournament_events = @recurring_tournament.tournament_events.order(date: :desc)
    @duo_tournament_events = @recurring_tournament.duo_tournament_events.order(date: :desc)
  end

  def modal
    render :modal, layout: false
  end

  private

  def set_recurring_tournament
    @recurring_tournament = RecurringTournament.find(params[:id])
  end

end
