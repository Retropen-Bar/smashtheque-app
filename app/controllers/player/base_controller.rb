class Player::BaseController < ActionController::Base
  # layout 'player'

  before_action :authenticate_player!
end
