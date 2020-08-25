class Api::V1::BaseController < ApiController

  skip_before_action :verify_authenticity_token

  before_action :authenticate_request!
  before_action :log_request!

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end

  def authenticate_request!
    @api_token = ApiToken.find_by(token: bearer_token)
    head :unauthorized and return if @api_token.nil?
  end

  def log_request!
    ApiRequest.create!(
      api_token: @api_token,
      remote_ip: request.remote_ip,
      controller: params[:controller],
      action: params[:action],
      requested_at: Time.now
    )
  end

  def render_errors(errors, status)
    puts "[API] Responding with errors: #{errors.to_json}"
    render json: {
      errors: errors
    }, status: status
  end

  def record_not_found
    head :not_found and return
  end

end
