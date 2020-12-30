class ApplicationController < ActionController::Base

  before_action :set_time_zone
  before_action :set_locale

  def status
    render plain: 'OK', status: 200
  end

  protected

  def user_for_paper_trail
    admin_user_signed_in? ? [current_admin_user.id, current_admin_user.discord_user_username].join(':') : '0:anonymous'
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
    character = Character.order("RANDOM()").first.decorate
    @background_color = character.background_color
    @background_image_url = character.background_image_data_url
    @background_size = character.background_size || 128
  end

end
