class PublicController < ApplicationController

  before_action :check_access!, except: :rollbar_test

  def home
    @players_count = Player.count
    @teams_count = Team.count
  end

  def rollbar_test
    raise "This is a test"
  end

  private

  def check_access!
    # for the first time
    session[:token] = params[:token] if params[:token]

    # check
    authenticate_admin_user! unless session[:token] == ENV['PUBLIC_ACCESS_TOKEN']
  end

end
