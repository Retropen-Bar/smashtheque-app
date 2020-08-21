class CitiesController < PublicController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  def index
    @cities = apply_scopes(City).all
  end

end
