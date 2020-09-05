class ActiveAdmin::ApiRequestDecorator < ApiRequestDecorator
  include ActiveAdmin::BaseDecorator

  decorates :api_request

end
