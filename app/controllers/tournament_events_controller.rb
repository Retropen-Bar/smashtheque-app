class TournamentEventsController < PublicController
  helper_method :user_recurring_tournament_admin?

  before_action :set_recurring_tournament, only: %w[new create]
  before_action :set_tournament_event, only: %w[show edit update top8_modal]
  decorates_assigned :tournament_event

  before_action :verify_tournament_event!, only: %w[new create edit update]

  has_scope :page, default: 1
  has_scope :per

  def index
    @tournament_events = apply_scopes(TournamentEvent.visible.order(date: :desc)).all
    respond_to do |format|
      format.html do
        @meta_title = 'Éditions passées'
        render layout: 'application_v2'
      end
      format.ics do
        render plain: ics_cal.to_ical
      end
    end
  end

  def new
    @tournament_event = @recurring_tournament.tournament_events.new
  end

  def create
    @tournament_event = @recurring_tournament.tournament_events.new(tournament_event_params)
    # auto-complete with data from bracket API
    @tournament_event.complete_with_bracket

    if (bracket = @tournament_event.bracket) && TournamentEvent.where(bracket: bracket).any?
      # this tournament is already known: display an error
      @tournament_event.errors.add(:bracket_url, :unique)
      render :new and return
    end

    if @tournament_event.save
      redirect_to [:edit, @tournament_event]
    else
      render :new
    end
  end

  def show
    redirect_to root_path and return if @tournament_event.hidden?

    @meta_title = @tournament_event.name
    @meta_properties['og:type'] = 'profile'
    if @recurring_tournament
      @meta_properties['og:image'] = @recurring_tournament.decorate.discord_guild_icon_image_url
    end
    render layout: 'application_v2'
  end

  def edit; end

  def update
    @tournament_event.attributes = tournament_event_params
    if @tournament_event.save
      redirect_to @tournament_event
    else
      render :edit
    end
  end

  def top8_modal
    render 'top8_modal', layout: false
  end

  private

  def set_recurring_tournament
    @recurring_tournament = RecurringTournament.find(params[:recurring_tournament_id])
  end

  def set_tournament_event
    @tournament_event = TournamentEvent.find(params[:id])
    @recurring_tournament = @tournament_event.recurring_tournament
  end

  def verify_tournament_event!
    authenticate_user!
    return if current_user.is_admin? || user_recurring_tournament_admin?

    flash[:error] = 'Accès non autorisé'
    redirect_to @tournament_event
  end

  def user_recurring_tournament_admin?
    return false unless user_signed_in?
    return false if @recurring_tournament.nil?

    @recurring_tournament.contacts.each do |user|
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

  def ics_cal
    cal = Icalendar::Calendar.new
    cal.x_wr_calname = 'Smashthèque'
    @tournament_events.each do |tournament_event|
      event = tournament_event.decorate.as_ical_event
      event.url = polymorphic_url tournament_event
      event.description += "\nPlus d'infos : #{event.url}"
      cal.add_event event
    end
    cal.publish
    cal
  end
end
