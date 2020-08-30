class Api::V1::LocationsController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_name_like

  def index
    locations = apply_scopes(Location).all
    render json: locations
  end

  def create
    attributes = location_create_params
    location = Location.new(attributes)
    if location.save
      render json: location, status: :created
    else
      render_errors location.errors, :unprocessable_entity
    end
  end

  private

  def location_create_params
    params.require(:location).permit(:name, :icon)
  end

end
