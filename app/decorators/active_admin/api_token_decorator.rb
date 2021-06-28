module ActiveAdmin
  class ApiTokenDecorator < ApiTokenDecorator
    include ActiveAdmin::BaseDecorator

    decorates :api_token

    def api_requests_admin_path
      admin_api_requests_path(q: { api_token_id_eq: model.id })
    end

    def api_requests_admin_link
      h.link_to api_requests_count, api_requests_admin_path
    end
  end
end
