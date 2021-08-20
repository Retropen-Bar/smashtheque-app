class ProblemsController < PublicController
  helper_method :user_recurring_tournament_admin?

  before_action :set_recurring_tournament
  before_action :set_problem, only: %w[show edit update]
  decorates_assigned :recurring_tournament
  decorates_assigned :problem

  before_action :verify_problem!, only: %w[new create]

  has_scope :page, default: 1
  has_scope :per

  def index
    @problems = apply_scopes(
      @recurring_tournament.problems.order(occurred_at: :desc)
    ).all
  end

  def show; end

  def new
    @problem = @recurring_tournament.problems.new(occurred_at: Time.current)
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

  def verify_problem!
    authenticate_user!
    return if current_user.is_admin? || user_recurring_tournament_admin?

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
    params.require(:problem).permit(
      :player_id, :duo_id,
      :occurred_at, :nature, :details, :proof
    )
  end
end
