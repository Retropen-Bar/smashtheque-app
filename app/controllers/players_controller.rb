class PlayersController < PublicController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  def index
    @players = players Player.all
  end

  def city_index
    @city = City.find(params[:id]).decorate
    @players = players @city.model.players
    render 'cities/show'
  end

  def team_index
    @team = Team.find(params[:id]).decorate
    @players = players @team.model.players
    render 'teams/show'
  end

  def character_index
    @character = Character.find(params[:id]).decorate
    @players = players @character.model.players
    render 'characters/show'
  end

  def show
    @player = Player.find(params[:id])
  end

  private

  def players(base)
    apply_scopes(base.order(:name)).includes(:team, :city, :characters)
  end

end
