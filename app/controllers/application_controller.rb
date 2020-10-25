class ApplicationController < ActionController::Base

  before_action :set_time_zone
  before_action :set_locale

  def status
    render plain: 'OK', status: 200
  end

  protected

  def user_for_paper_trail
    user_signed_in? ? [current_user.id, current_user.discord_user_username].join(':') : '0:anonymous'
  end

  def access_denied(error)
    render plain: 'Unauthorized', status: :unauthorized
  end

  private

  def set_time_zone
    if time_zone = cookies[:time_zone]
      Time.zone = ActiveSupport::TimeZone[time_zone]
    end
  end

  def set_locale
    I18n.locale = :fr
  end

  def set_static_page
    @static = true
  end

end
