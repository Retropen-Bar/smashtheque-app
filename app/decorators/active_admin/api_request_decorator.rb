module ActiveAdmin
  class ApiRequestDecorator < ApiRequestDecorator
    include ActiveAdmin::BaseDecorator

    decorates :api_request
  end
end
