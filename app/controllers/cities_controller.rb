class CitiesController < PublicController

  has_scope :page, default: 1
  has_scope :per

  def index
    @cities = apply_scopes(City).all
  end

  def show
    @city = City.find(params[:id]).decorate
    @players = apply_scopes(@city.model.players)
  end

end
