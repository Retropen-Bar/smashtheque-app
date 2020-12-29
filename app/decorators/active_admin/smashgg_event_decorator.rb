class ActiveAdmin::SmashggEventDecorator < SmashggEventDecorator
  include ActiveAdmin::BaseDecorator

  decorates :smashgg_event

  def admin_link(options = {})
    super({label: full_name}.merge(options))
  end

  def tournament_event_admin_link(options = {})
    tournament_event&.admin_decorate&.admin_link(options)
  end

end
