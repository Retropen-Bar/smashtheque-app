class ActiveAdmin::DuoTournamentEventDecorator < DuoTournamentEventDecorator
  include ActiveAdmin::TournamentEventBaseDecorator

  decorates :duo_tournament_event

  DuoTournamentEvent::DUO_NAMES.each do |duo_name|
    define_method "#{duo_name}_admin_link" do
      send(duo_name)&.admin_decorate&.admin_link
    end
  end

  def first_duo_tournament_event_admin_link(options = {})
    duo_tournament_event = first_duo_tournament_event
    if duo_tournament_event
      duo_tournament_event.admin_decorate.admin_link(options)
    else
      h.link_to options[:label], '#', class: 'disabled'
    end
  end

  def previous_duo_tournament_event_admin_link(options = {})
    duo_tournament_event = previous_duo_tournament_event
    if duo_tournament_event
      duo_tournament_event.admin_decorate.admin_link(options)
    else
      h.link_to options[:label], '#', class: 'disabled'
    end
  end

  def next_duo_tournament_event_admin_link(options = {})
    duo_tournament_event = next_duo_tournament_event
    if duo_tournament_event
      duo_tournament_event.admin_decorate.admin_link(options)
    else
      h.link_to options[:label], '#', class: 'disabled'
    end
  end

  def last_duo_tournament_event_admin_link(options = {})
    duo_tournament_event = last_duo_tournament_event
    if duo_tournament_event
      duo_tournament_event.admin_decorate.admin_link(options)
    else
      h.link_to options[:label], '#', class: 'disabled'
    end
  end

end
