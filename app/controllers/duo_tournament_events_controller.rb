class DuoTournamentEventsController < PublicController
  helper_method :user_recurring_tournament_admin?

  before_action :set_recurring_tournament, only: %w[new create]
  before_action :set_duo_tournament_event, only: %w[show edit update]
  decorates_assigned :duo_tournament_event

  before_action :verify_duo_tournament_event!, only: %w[new create edit update]

  has_scope :page, default: 1
  has_scope :per

  def index
    @duo_tournament_events = apply_scopes(DuoTournamentEvent.visible.order(date: :desc)).all
    respond_to do |format|
      format.html do
        @meta_title = 'Éditions 2v2 passées'
      end
      format.ics do
        render plain: ics_cal.to_ical
      end
    end
  end

  def new
    @duo_tournament_event = @recurring_tournament.duo_tournament_events.new
  end

  def create
    @duo_tournament_event = @recurring_tournament.duo_tournament_events.new(
      duo_tournament_event_params
    )
    # auto-complete with data from bracket API
    @duo_tournament_event.complete_with_bracket

    if (bracket = @duo_tournament_event.bracket) && DuoTournamentEvent.where(bracket: bracket).any?
      # this tournament is already known: display an error
      @duo_tournament_event.errors.add(:bracket_url, :unique)
      render :new and return
    end

    if @duo_tournament_event.save
      redirect_to [:edit, @duo_tournament_event]
    else
      render :new
    end
  end

  def show
    @meta_title = @duo_tournament_event.name
    @meta_properties['og:type'] = 'profile'
    if @recurring_tournament
      @meta_properties['og:image'] = @recurring_tournament.decorate.discord_guild_icon_image_url
    end
  end

  def edit; end

  def update
    @duo_tournament_event.attributes = duo_tournament_event_params
    if @duo_tournament_event.save
      redirect_to @duo_tournament_event
    else
      render :edit
    end
  end

  private

  def set_recurring_tournament
    @recurring_tournament = RecurringTournament.find(params[:recurring_tournament_id])
  end

  def set_duo_tournament_event
    @duo_tournament_event = DuoTournamentEvent.find(params[:id])
    @recurring_tournament = @duo_tournament_event.recurring_tournament
  end

  def verify_duo_tournament_event!
    authenticate_user!
    return if current_user.is_admin? || user_recurring_tournament_admin?

    flash[:error] = 'Accès non autorisé'
    redirect_to @duo_tournament_event and return
  end

  def user_recurring_tournament_admin?
    return false unless user_signed_in?
    return false if @recurring_tournament.nil?

    @recurring_tournament.contacts.each do |user|
      return true if user == current_user
    end
    false
  end

  def duo_tournament_event_params
    params.require(:duo_tournament_event).permit(
      :name, :date, :participants_count, :bracket_url,
      :top1_duo_id, :top2_duo_id, :top3_duo_id,
      :top4_duo_id, :top5a_duo_id, :top5b_duo_id,
      :top7a_duo_id, :top7b_duo_id,
      :graph
    )
  end

  def ics_cal
    cal = Icalendar::Calendar.new
    cal.x_wr_calname = 'Smashthèque 2v2'
    @duo_tournament_events.each do |duo_tournament_event|
      event = duo_tournament_event.decorate.as_ical_event
      event.url = polymorphic_url duo_tournament_event
      event.description += "\nPlus d'infos : #{event.url}"
      cal.add_event event
    end
    cal.publish
    cal
  end
end
