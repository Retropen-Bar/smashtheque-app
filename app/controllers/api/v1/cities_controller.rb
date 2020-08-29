class Api::V1::CitiesController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_name_like

  def index
    cities = apply_scopes(City).all
    render json: cities
  end

  def create
    attributes = city_create_params
    city = City.new(attributes)
    if city.save
      render json: city, status: :created
    else
      render_errors city.errors, :unprocessable_entity
    end
  end

  private

  def city_create_params
    params.require(:city).permit(:name, :icon)
  end

end
