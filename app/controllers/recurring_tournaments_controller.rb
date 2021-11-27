class RecurringTournamentsController < PublicController
  helper_method :user_recurring_tournament_admin?

  before_action :set_recurring_tournament, only: %w[show modal edit update]
  before_action :verify_recurring_tournament!, only: %w[edit update]
  decorates_assigned :recurring_tournament

  has_scope :by_community_id
  has_scope :by_level_in, type: :array
  has_scope :by_size_geq
  has_scope :by_size_leq
  has_scope :by_is_online
  has_scope :by_events_count_geq
  has_scope :by_is_not_archived, type: :boolean, default: false, allow_blank: true do |_, scope, value|
    if value
      scope.not_archived
    else
      scope
    end
  end
  has_scope :administrated_by
  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  layout 'application_v2'

  def index
    @not_archived_only = params[:by_is_not_archived]&.to_i == 1
    respond_to do |format|
      format.html do
        index_html
      end
      format.json do
        index_json
      end
      format.ics do
        index_ical
      end
    end
  end

  def index_html
    @recurring_tournaments = apply_scopes(
      RecurringTournament.visible.order('lower(name)')
    )
    @recurring_tournaments = @recurring_tournaments.recurring.not_archived if @map
    @recurring_tournaments = @recurring_tournaments.includes(:discord_guild).all
    @meta_title = 'Tournois'
  end

  def index_json
    start = params[:startStr] ? Date.parse(params[:startStr]) : Time.now
    render json: apply_scopes(
      RecurringTournament.visible.recurring.not_archived
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
      RecurringTournament.visible.recurring.not_archived
    ).per(1000).all.decorate.each do |recurring_tournament|
      event = recurring_tournament.as_ical_event
      event.url = polymorphic_url recurring_tournament
      event.description += "\nPlus d'infos : #{event.url}"
      cal.add_event event
    end

    cal.publish
    render plain: cal.to_ical
  end

  def map
    @recurring_tournaments = apply_scopes(
      RecurringTournament.visible.order('LOWER(name)')
    ).includes(:discord_guild).all
    @meta_title = 'Carte des tournois'
    render layout: 'map'
  end

  def show
    redirect_to root_path and return if @recurring_tournament.hidden?

    @tournament_events = @recurring_tournament.tournament_events.order(date: :desc)
    @duo_tournament_events = @recurring_tournament.duo_tournament_events.order(date: :desc)
    @meta_title = @recurring_tournament.name
    @meta_properties['og:type'] = 'profile'
    @meta_properties['og:image'] = @recurring_tournament.decorate.discord_guild_icon_image_url
  end

  def modal
    render :modal, layout: false
  end

  def edit; end

  def update
    @recurring_tournament.attributes = recurring_tournament_params
    if @recurring_tournament.save
      redirect_to @recurring_tournament
    else
      render :edit
    end
  end

  protected

  def current_page_params
    params.permit(
      :by_size_geq, :by_size_leq, :by_is_online,
      :page, :per, :on_abc,
      by_level_in: []
    )
  end

  private

  def set_recurring_tournament
    @recurring_tournament = RecurringTournament.find(params[:id])
  end

  def verify_recurring_tournament!
    authenticate_user!
    return if current_user.is_admin? || user_recurring_tournament_admin?

    flash[:error] = 'Accès non autorisé'
    redirect_to @recurring_tournament
  end

  def user_recurring_tournament_admin?
    return false unless user_signed_in?

    @recurring_tournament.contacts.each do |user|
      return true if user == current_user
    end
    false
  end

  def recurring_tournament_params
    params.require(:recurring_tournament).permit(
      :name, :recurring_type, :logo,
      :date_description, :wday, :starts_at_hour, :starts_at_min,
      :discord_guild_id, :is_online, :level, :size, :registration,
      :address_name, :address, :latitude, :longitude,
      :locality, :countrycode,
      :twitter_username, :misc,
      :is_archived
    )
  end
end
