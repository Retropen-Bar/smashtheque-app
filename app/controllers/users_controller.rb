class UsersController < PublicController
  before_action :set_user, except: :me
  before_action :verify_user!
  before_action :verify_user_ban!, only: %i[edit update]
  decorates_assigned :user

  def show; end

  def me
    redirect_to current_user
  end

  def edit; end

  def refetch
    if @user.refetch
      redirect_back fallback_location: { action: :show }, notice: 'Données mises à jour' and return
    end

    flash[:error] = 'Impossible de mettre à jour les données'
    redirect_back fallback_location: { action: :show }
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
      redirect_back fallback_location: { action: :show }, notice: 'Fiche joueur déjà existante'
      return
    end

    @user.create_player!(
      name: @user.name,
      creator_user: @user,
      is_accepted: @user == current_user
    )
    redirect_to action: :edit
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def verify_user!
    authenticate_user!
    return if current_user.is_admin? || current_user == @user

    flash[:error] = 'Accès non autorisé'
    redirect_to root_path and return
  end

  def verify_user_ban!
    return unless @user.player&.is_banned?

    flash[:error] = 'Modification non autorisée'
    redirect_to root_path and return
  end

  def user_params
    params.require(:user).permit(%i[
      name twitter_username
      is_caster
      is_coach coaching_url coaching_details
      is_graphic_designer graphic_designer_details is_available_graphic_designer
      main_address main_latitude main_longitude main_locality main_countrycode
      secondary_address secondary_latitude secondary_longitude
      secondary_locality secondary_countrycode
    ] + [{
      player_attributes: %i[
        id
        name
      ] + [{
        character_ids: [],
        team_ids: []
      }]
    }])
  end
end
