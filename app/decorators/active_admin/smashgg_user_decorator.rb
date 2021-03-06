module ActiveAdmin
  class SmashggUserDecorator < SmashggUserDecorator
    include ActiveAdmin::BaseDecorator

    decorates :smashgg_user

    def admin_link(options = {})
      size = options.delete(:size) || 32
      super({ label: avatar_and_name(size: size) }.merge(options))
    end

    def player_admin_link(options = {})
      player&.admin_decorate&.admin_link(options)
    end
  end
end
