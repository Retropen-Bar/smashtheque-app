class ActiveAdmin::SmashggEventDecorator < SmashggEventDecorator
  include ActiveAdmin::BaseDecorator

  decorates :smashgg_event

  def admin_link(options = {})
    super({label: full_name}.merge(options))
  end

  def tournament_event_admin_link(options = {})
    tournament_event&.admin_decorate&.admin_link(options)
  end

  SmashggEvent::USER_NAMES.each do |user_name|
    define_method "#{user_name}_admin_link" do
      send(user_name)&.admin_decorate&.admin_link
    end
  end

end
