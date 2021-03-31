class UsersController < PublicController

  before_action :set_user
  before_action :verify_user!
  before_action :verify_user_ban!, only: %i(edit update)
  decorates_assigned :user

  def show

  end

  def edit

  end

  def update
    @user.attributes = user_params
    if @user.save
      redirect_to @user
    else
      render :edit
    end
  end

  def create_player
    if @user.player
      redirect_to request.referrer, notice: 'Fiche joueur déjà existante' and return
    end
    @user.create_player!(
      name: @user.name,
      creator_user: @user
    )
    redirect_to action: :edit
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def verify_user!
    authenticate_user!
    unless current_user.is_admin? || current_user == @user
      flash[:error] = 'Accès non autorisé'
      redirect_to root_path and return
    end
  end

  def verify_user_ban!
    if @user.player&.is_banned?
      flash[:error] = 'Modification non autorisée'
      redirect_to root_path and return
    end
  end

  def user_params
    params.require(:user).permit(%i(
      name twitter_username
      is_caster
      is_coach coaching_url coaching_details
      is_graphic_designer graphic_designer_details is_available_graphic_designer
      main_address main_latitude main_longitude
      secondary_address secondary_latitude secondary_longitude
    ) + [{
      player_attributes: %i(
        id
        name
      ) + [{
        character_ids: [],
        team_ids: []
      }]
    }])
  end

end
