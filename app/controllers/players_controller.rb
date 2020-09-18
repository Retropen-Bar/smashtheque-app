class PlayersController < PublicController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  layout :select_layout

  def index
    @players = players Player.all
  end

  def location_index
    @location = Location.find(params[:id]).decorate
    @players = players @location.model.players
    render 'locations/show'
  end

  def team_index
    @team = Team.find(params[:id]).decorate
    @players = players @team.model.players
    render 'teams/show'
  end

  def character_index
    @character = Character.find(params[:id]).decorate
    @players = players @character.model.players
    @background_color = @character.background_color
    @background_image_url = @character.background_image_data_url
    @background_size = @character.background_size || 128
    render 'characters/show'
  end

  def show
    @player = Player.find(params[:id])
    main_character = @player.characters.first&.decorate
    if main_character
      @background_color = main_character.background_color
      @background_image_url = main_character.background_image_data_url
      @background_size = main_character.background_size || 128
    end
  end

  private

  def players(base)
    @map = params[:map].to_i == 1
    apply_scopes(base.accepted.order(:name)).includes(:discord_user, :teams, :locations, :characters)
  end

  def select_layout
    @map ? 'map' : 'application'
  end

end
