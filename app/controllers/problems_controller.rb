class ProblemsController < PublicController
  helper_method :user_recurring_tournament_admin?

  before_action :set_recurring_tournament
  before_action :set_problem, only: %w[show edit update]
  decorates_assigned :recurring_tournament
  decorates_assigned :problem

  before_action :verify_recurring_tournament!, except: :show
  before_action :verify_charted!, only: :show

  has_scope :page, default: 1
  has_scope :per

  def index
    @problems = apply_scopes(
      @recurring_tournament.problems.order(occurred_at: :desc)
    ).all
  end

  def show; end

  def new
    @problem = @recurring_tournament.problems.new(
      problem_params.merge(occurred_at: Time.current)
    )
  end

  def create
    @problem = @recurring_tournament.problems.new(
      problem_params.merge(reporting_user: current_user)
    )

    if @problem.save
      redirect_to [@recurring_tournament, @problem]
    else
      render :new
    end
  end

  def edit; end

  def update
    @problem.attributes = problem_params
    if @problem.save
      redirect_to [@recurring_tournament, @problem]
    else
      render :edit
    end
  end

  private

  def set_recurring_tournament
    @recurring_tournament = RecurringTournament.find(params[:recurring_tournament_id])
  end

  def set_problem
    @problem = Problem.find(params[:id])
  end

  def verify_recurring_tournament!
    authenticate_user!
    return if current_user.is_admin?
    return if user_recurring_tournament_admin? && @recurring_tournament.has_signed_charter?

    flash[:error] = 'Accès non autorisé'
    redirect_to root_path
  end

  def verify_charted!
    authenticate_user!
    return if current_user.is_admin? || user_charted?

    flash[:error] = 'Accès non autorisé'
    redirect_to root_path
  end

  def user_recurring_tournament_admin?
    return false unless user_signed_in?
    return false if @recurring_tournament.nil?

    @recurring_tournament.contacts.each do |user|
      return true if user == current_user
    end
    false
  end

  def problem_params
    return {} unless params[:problem]

    params.require(:problem).permit(
      :player_id, :duo_id,
      :occurred_at, :nature, :details, :proof
    )
  end
end