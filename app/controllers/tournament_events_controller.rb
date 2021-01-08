class TournamentEventsController < PublicController

  decorates_assigned :tournament_event

  has_scope :page, default: 1
  has_scope :per

  def index
    @tournament_events = apply_scopes(TournamentEvent.order(date: :desc)).all
    respond_to do |format|
      format.html do
        # nothing special
      end
      format.ics do
        cal = Icalendar::Calendar.new
        cal.x_wr_calname = 'Smashthèque'
        @tournament_events.each do |tournament_event|
          cal.add_event(
            tournament_event.decorate.as_ical_event(host: request.host)
          )
        end
        cal.publish
        render plain: cal.to_ical
      end
    end
  end

  def show
    @tournament_event = TournamentEvent.find(params[:id])
  end

end
