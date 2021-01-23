class DuoTournamentEventsController < PublicController

  decorates_assigned :duo_tournament_event

  has_scope :page, default: 1
  has_scope :per

  def index
    @duo_tournament_events = apply_scopes(DuoTournamentEvent.order(date: :desc)).all
    respond_to do |format|
      format.html do
        # nothing special
      end
      format.ics do
        cal = Icalendar::Calendar.new
        cal.x_wr_calname = 'Smashthèque 2v2'
        @duo_tournament_events.each do |duo_tournament_event|
          event = duo_tournament_event.decorate.as_ical_event
          event.url = polymorphic_url duo_tournament_event
          event.description += "\nPlus d'infos : #{event.url}"
          cal.add_event event
        end
        cal.publish
        render plain: cal.to_ical
      end
    end
  end

  def show
    @duo_tournament_event = DuoTournamentEvent.find(params[:id])
  end

end
