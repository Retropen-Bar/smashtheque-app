class Api::V1::TeamsController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_short_name_like

  def index
    teams = apply_scopes(Team).all
    render json: teams
  end

end
