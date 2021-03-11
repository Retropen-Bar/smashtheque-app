class ActiveAdmin::TournamentEventDecorator < TournamentEventDecorator
  include ActiveAdmin::TournamentEventBaseDecorator

  decorates :tournament_event

  TournamentEvent::PLAYER_NAMES.each do |player_name|
    define_method "#{player_name}_admin_link" do
      send(player_name)&.admin_decorate&.admin_link
    end
  end

  def first_tournament_event_admin_link(options = {})
    tournament_event = first_tournament_event
    if tournament_event
      tournament_event.admin_decorate.admin_link(options)
    else
      h.link_to options[:label], '#', class: 'disabled'
    end
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

  def last_tournament_event_admin_link(options = {})
    tournament_event = last_tournament_event
    if tournament_event
      tournament_event.admin_decorate.admin_link(options)
    else
      h.link_to options[:label], '#', class: 'disabled'
    end
  end

end
