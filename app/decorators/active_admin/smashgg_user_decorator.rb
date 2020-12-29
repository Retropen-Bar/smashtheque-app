class ActiveAdmin::SmashggUserDecorator < SmashggUserDecorator
  include ActiveAdmin::BaseDecorator

  decorates :smashgg_user

  def admin_link(options = {})
    size = options.delete(:size) || 32
    super({label: full_name(max_height: size)}.merge(options))
  end

  def player_admin_link(options = {})
    player&.admin_decorate&.admin_link(options)
  end

end
