class ApplicationController < ActionController::Base

  before_action :set_time_zone

  def status
    render plain: 'OK', status: 200
  end

  protected

  def user_for_paper_trail
    admin_user_signed_in? ? [current_admin_user.id, current_admin_user.discord_user_username].join(':') : '0:anonymous'
  end

  private

  def set_time_zone
    if time_zone = cookies[:time_zone]
      Time.zone = ActiveSupport::TimeZone[time_zone]
    end
  end

end
