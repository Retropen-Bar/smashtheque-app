class PublicController < ApplicationController

  helper_method :user_team_admin?

  before_action :check_access! if ENV['HIDE_WEBSITE']

  helper_method :render_map

  private

  def user_team_admin?
    return false unless user_signed_in?
    return false unless @team
    @team.admins.each do |user|
      return true if user == current_user
    end
    false
  end

  def check_access!
    # for the first time
    session[:token] = params[:token] if params[:token]

    # check
    authenticate_admin_user! unless session[:token] == ENV['PUBLIC_ACCESS_TOKEN']
  end

  def render_map(locals)
    render_to_string partial: 'shared/map', layout: false, locals: locals
  end

end
