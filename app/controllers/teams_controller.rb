class TeamsController < PublicController

  has_scope :page, default: 1
  has_scope :per

  def index
    @teams = apply_scopes(Team).all
  end

  def show
    @team = Team.find(params[:id]).decorate
    @players = apply_scopes(@team.model.players)
  end

end
