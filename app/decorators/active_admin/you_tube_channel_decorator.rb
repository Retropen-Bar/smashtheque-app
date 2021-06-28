module ActiveAdmin
  class YouTubeChannelDecorator < YouTubeChannelDecorator
    include ActiveAdmin::BaseDecorator

    decorates :you_tube_channel

    def related_admin_link(options = {})
      related&.admin_decorate&.admin_link(options)
    end
  end
end
