class Api::V1::CitiesController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_name_like

  def index
    cities = apply_scopes(City).all
    render json: cities
  end

end
