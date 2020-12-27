class PublicController < ApplicationController

  before_action :check_access! if ENV['HIDE_WEBSITE']

  def home
    @players_count = Rails.env.development? ? 4149 : Player.count
    @teams_count = Rails.env.development? ? 136 : Team.count
    @recurring_tournaments_count = Rails.env.development? ? 73 : RecurringTournament.count
    @tournament_events_count = Rails.env.development? ? 1050 : TournamentEvent.count
  end

  def planning_online
    @monday = Date.today.beginning_of_week
  end

  private

  def check_access!
    # for the first time
    session[:token] = params[:token] if params[:token]

    # check
    authenticate_admin_user! unless session[:token] == ENV['PUBLIC_ACCESS_TOKEN']
  end

end
