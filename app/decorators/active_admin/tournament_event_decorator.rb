class ActiveAdmin::TournamentEventDecorator < TournamentEventDecorator
  include ActiveAdmin::BaseDecorator

  decorates :tournament_event

  TournamentEvent::PLAYER_NAMES.each do |player_name|
    define_method "#{player_name}_admin_link" do
      send(player_name)&.admin_decorate&.admin_link
    end
  end

  def recurring_tournament_admin_link(options = {})
    recurring_tournament&.admin_decorate&.admin_link(options)
  end

  def previous_tournament_event_admin_link(options = {})
    tournament_event = previous_tournament_event
    if tournament_event
      tournament_event.admin_decorate.admin_link(options)
    else
      h.link_to options[:label], '#', class: 'disabled'
    end
  end

  def next_tournament_event_admin_link(options = {})
    tournament_event = next_tournament_event
    if tournament_event
      tournament_event.admin_decorate.admin_link(options)
    else
      h.link_to options[:label], '#', class: 'disabled'
    end
  end

  def smashgg_event_admin_link(options = {})
    smashgg_event&.admin_decorate&.admin_link(options)
  end

end
