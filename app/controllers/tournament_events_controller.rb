class TournamentEventsController < PublicController

  helper_method :user_recurring_tournament_admin?

  before_action :set_tournament_event, only: %w(show edit update)
  before_action :verify_tournament_event!, only: %w(edit update)
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
          event = tournament_event.decorate.as_ical_event
          event.url = polymorphic_url tournament_event
          event.description += "\nPlus d'infos : #{event.url}"
          cal.add_event event
        end
        cal.publish
        render plain: cal.to_ical
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    @tournament_event.attributes = tournament_event_params
    if @tournament_event.save
      redirect_to @tournament_event
    else
      render :edit
    end
  end

  private

  def set_tournament_event
    @tournament_event = TournamentEvent.find(params[:id])
  end

  def verify_tournament_event!
    authenticate_user!
    unless current_user.is_admin? || user_recurring_tournament_admin?
      flash[:error] = 'Accès non autorisé'
      redirect_to @tournament_event and return
    end
  end

  def user_recurring_tournament_admin?
    return false unless user_signed_in?
    @tournament_event.recurring_tournament.contacts.each do |user|
      return true if user == current_user
    end
    false
  end

  def tournament_event_params
    params.require(:tournament_event).permit(
      :name, :date, :participants_count, :bracket_url,
      :top1_player_id, :top2_player_id, :top3_player_id,
      :top4_player_id, :top5a_player_id, :top5b_player_id,
      :top7a_player_id, :top7b_player_id,
      :graph
    )
  end

end
