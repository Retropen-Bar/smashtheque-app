module ActiveAdmin
  class TwitchChannelDecorator < TwitchChannelDecorator
    include ActiveAdmin::BaseDecorator

    decorates :twitch_channel

    def related_admin_link(options = {})
      related&.admin_decorate&.admin_link(options)
    end
  end
end
