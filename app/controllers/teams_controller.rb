class TeamsController < PublicController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  def index
    @teams = apply_scopes(Team).all
  end

end
