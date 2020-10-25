class Player::PlayerController < Player::BaseController

  before_action :set_player

  def show
  end

  def edit
  end

  def update
    if @player.update(player_params)
      redirect_to action: :show, notice: 'Compte mise à jour.'
    else
      render :edit
    end
  end

  private

  def set_player
    @player = current_player
  end

  def player_params
    params.require(:player).permit(:email)
  end

end
