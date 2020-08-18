class PlayersController < PublicController

  has_scope :page, default: 1
  has_scope :per

  def index
    @players = apply_scopes(Player).all
  end

end
