class TeamsController < PublicController
  before_action :set_team, only: %w[show edit update]
  before_action :verify_team!, only: %w[edit update]
  decorates_assigned :team

  has_scope :by_is_online
  has_scope :by_is_offline
  has_scope :by_is_sponsor
  has_scope :administrated_by
  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  layout 'application_v2'

  def index
    @teams = apply_scopes(Team.order('lower(name)')).all
    @meta_title = 'Équipes'
  end

  def show
    @online_rewards_counts = @team.rewards_counts(is_online: true)
    @offline_rewards_counts = @team.rewards_counts(is_online: false)
    @all_online_rewards = Reward.online_1v1.includes(image_attachment: :blob)
    @all_offline_rewards = Reward.offline_1v1.includes(image_attachment: :blob)
    @meta_title = @team.name
    @meta_properties['og:type'] = 'profile'
    @meta_properties['og:image'] = team.any_image_url
  end

  def edit; end

  def update
    @team.attributes = team_params
    if @team.save
      redirect_to @team
    else
      render :edit
    end
  end
  
  def ranking
    @year = params[:year]&.to_i
    @year = nil unless @year&.positive?
    @is_online = params[:is_online]&.to_i != 0

    @teams = apply_scopes(
      Team.ranking(is_online: @is_online, year: @year)
    ).includes(
      logo_attachment: :blob
    )

    @meta_title = [
      "Observatoire d'Harmonie des équipes",
      @is_online ? 'Online' : 'Offline',
      @year
    ].compact.join(' ')
    render layout: 'application'
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def verify_team!
    authenticate_user!
    unless current_user.is_admin? || user_team_admin?
      flash[:error] = 'Accès non autorisé'
      redirect_to @team and return
    end
  end

  def team_params
    params.require(:team).permit(
      :short_name, :name, :logo, :roster, :twitter_username,
      :is_offline, :is_online, :is_sponsor,
      :website_url, :creation_year, :is_recruiting, :recruiting_details, :description,
      player_ids: []
    )
  end

  def current_page_params
    params.permit(
      :by_is_online, :by_is_offline, :by_is_sponsor,
      :administrated_by,
      :page, :per, :on_abc
    )
  end
end
