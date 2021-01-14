class Api::V1::PlayersController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_discord_id, allow_blank: true
  has_scope :by_name
  has_scope :by_name_like

  def index
    players = apply_scopes(Player.order(:name)).includes(
      :characters, :locations, :creator, :discord_user, :teams
    )
    render json: players.as_json(reload: params[:reload] != '0')
  end

  def show
    player = Player.find(params[:id])
    render json: player
  end

  def create
    attributes = player_create_params
    name_confirmation = attributes.delete(:name_confirmation) == true

    existing_players = Player.by_name_like(attributes[:name]).pluck(:id)
    if existing_players.any? && !name_confirmation
      render_errors({ name: :already_known, existing_ids: existing_players }, :unprocessable_entity) and return
    end

    player = Player.new(attributes)
    # auto-accept players created by an admin
    player.is_accepted = true if player.creator&.user_is_admin?

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
    # TODO: remove :city_name when bot has been updated
    params.require(:player).permit(:name, :name_confirmation, :discord_id, :creator_discord_id, character_ids: [], location_ids: [], team_ids: [])
  end

  def player_update_params
    # TODO: remove :city_name when bot has been updated
    params.require(:player).permit(:name, :name_confirmation, :discord_id, character_ids: [], location_ids: [], team_ids: [])
  end

end
