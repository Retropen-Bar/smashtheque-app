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

  def show
    player = Player.find(params[:id])
    render json: player
  end

  def create
    attributes = player_create_params
    name_confirmation = attributes.delete(:name_confirmation) == true

    existing_players = Player.where(name: attributes[:name]).pluck(:id)
    if existing_players.any? && !name_confirmation
      render_errors({ name: :already_known, existing_ids: existing_players }, :unprocessable_entity) and return
    end

    player = Player.new(attributes)
    if player.save
      render json: player, status: :created
    else
      render_errors player.errors, :unprocessable_entity
    end
  end

  def update
    player = Player.find(params[:id])

    attributes = player_update_params
    name_confirmation = attributes.delete(:name_confirmation) == true

    if attributes[:name] != player.name
      existing_other_players = Player.where(name: attributes[:name]).pluck(:id)
      if existing_other_players.any? && !name_confirmation
        render_errors({ name: :already_known, existing_ids: existing_other_players }, :unprocessable_entity) and return
      end
    end

    player.attributes = attributes
    if player.save
      render json: player
    else
      render_errors player.errors, :unprocessable_entity
    end
  end

  private

  def player_create_params
    params.require(:player).permit(:name, :name_confirmation, :city_id, :team_id, :discord_id, :creator_discord_id, character_ids: [])
  end

  def player_update_params
    params.require(:player).permit(:name, :name_confirmation, :city_id, :team_id, :discord_id, character_ids: [])
  end

end