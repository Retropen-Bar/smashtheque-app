class UsersController < PublicController

  before_action :set_user
  before_action :verify_user!
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

  private

  def set_user
    @user = User.find(params[:id])
  end

  def verify_user!
    authenticate_user!
    # unless current_user.is_admin? || current_user == @user
    unless current_user == @user
      flash[:error] = 'Accès non autorisé'
      redirect_to root_path and return
    end
  end

  def user_params
    params.require(:user).permit(%i(
      name
      is_caster
      is_coach coaching_url coaching_details
      is_graphic_designer graphic_designer_details is_available_graphic_designer
    ) + [{
      player_attributes: %i(
        id
        name twitter_username
      ) + [{
        character_ids: [],
        location_ids: [],
        team_ids: []
      }]
    }])
  end

end
