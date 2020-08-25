class Api::V1::PlayersController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  def index
    players = apply_scopes(Player.order(:name)).includes(
      :characters, :city, :creator, :discord_user, :team
    )
    render json: players
  end

  def create
    attributes = player_params
    name_confirmation = attributes.delete(:name_confirmation) == true

    if Player.where(name: attributes[:name]).any? && !name_confirmation
      render json: {
        errors: {
          name: :already_known
        }
      }, status: :unprocessable_entity and return
    end

    player = Player.new(attributes)
    if player.save
      render json: player, status: :created
    else
      render json: { errors: player.errors }, status: :unprocessable_entity
    end
  end

  private

  def player_params
    params.require(:player).permit(:name, :name_confirmation, :city_id, :team_id, :discord_id, :creator_discord_id, character_ids: [])
  end

end
