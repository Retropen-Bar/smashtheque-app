class Api::V1::PlayersController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  def index
    players = apply_scopes(Player.order(:name)).includes(:team, :city, :characters)
    render json: players
  end

  def create
    attributes = player_params
    player = Player.new(attributes)
    if player.save
      render json: player, status: :created
    else
      render json: { errors: player.errors }, status: :unprocessable_entity
    end
  end

  private

  def player_params
    params.require(:player).permit(:name, :city_id, :team_id, character_ids: [])
  end

end
