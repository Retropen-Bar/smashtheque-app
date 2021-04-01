class SmashggUsersController < PublicController

  before_action :set_player, only: %w(new create)

  before_action :verify_player!, only: %w(new create)

  def new
    @smashgg_user = @player.smashgg_users.new
  end

  def create
    @smashgg_user = SmashggUser.new(smashgg_user_params)

    # refuse if not recognized
    if @smashgg_user.slug.blank?
      flash[:error] = 'Compte smash.gg non reconnu'
      redirect_to @player.user and return
    end

    # the account might be already known (linked or not)
    @smashgg_user = SmashggUser.where(slug: @smashgg_user.slug).first_or_initialize

    # refuse if the account was already known and linked to another player
    if @smashgg_user.player_id
      flash[:error] = 'Ce compte smash.gg est déjà relié à un autre joueur'
      redirect_to @player.user and return
    end

    @smashgg_user.fetch_smashgg_data
    @smashgg_user.player = @player
    if @smashgg_user.save
      redirect_to @player.user
    else
      render :new
    end
  end

  private

  def set_player
    @player = Player.find(params[:player_id])
  end

  def verify_player!
    authenticate_user!
    unless current_user.is_admin? || @player.user == current_user
      flash[:error] = 'Accès non autorisé'
      redirect_to @player and return
    end
  end

  def smashgg_user_params
    params.require(:smashgg_user).permit(
      :smashgg_url
    )
  end

end
