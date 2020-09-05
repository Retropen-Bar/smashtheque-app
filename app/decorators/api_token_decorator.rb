class ApiTokenDecorator < BaseDecorator

  def api_requests_count
    model.api_requests.count
  end

end
