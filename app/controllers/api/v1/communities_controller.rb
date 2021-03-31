class Api::V1::CommunitiesController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_name_like

  def index
    communities = apply_scopes(Community).all
    render json: communities
  end

end
