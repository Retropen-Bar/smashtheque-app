class ActiveAdmin::DuoTournamentEventDecorator < DuoTournamentEventDecorator
  include ActiveAdmin::TournamentEventBaseDecorator

  decorates :duo_tournament_event

  DuoTournamentEvent::DUO_NAMES.each do |duo_name|
    define_method "#{duo_name}_admin_link" do
      send(duo_name)&.admin_decorate&.admin_link
    end
  end

  TournamentEvent::PLAYER_RANKS.each do |rank|
    duo_name = "top#{rank}_duo".to_sym
    define_method "#{duo_name}_bracket_suggestion" do
      return nil if bracket.nil?
      case bracket_type.to_sym
      # when :SmashggEvent
      #   user_name = "top#{rank}_smashgg_duo".to_sym
      #   [
      #     'Bracket smash.gg',
      #     bracket.send(user_name)&.gamer_tag
      #   ].join(' : ')
      when :ChallongeTournament
        participant_name = "top#{rank}_participant_name".to_sym
        [
          'Bracket Challonge',
          bracket.send(participant_name)
        ].join(' : ')
      else
        nil
      end
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

end
