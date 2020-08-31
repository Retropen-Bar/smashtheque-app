class PublicController < ApplicationController

  def home
    @players_count = Player.count
    @teams_count = Team.count
  end

end
