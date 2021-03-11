class DuoTournamentEventDecorator < TournamentEventBaseDecorator

  def duo_rank(duo_id)
    DuoTournamentEvent::DUO_NAMES.each do |duo_name|
      return duo_name if send("#{duo_name}_id") == duo_id
    end
    nil
  end

  def duo_rank_name(duo_id)
    duo_name = duo_rank(duo_id)
    if duo_name
      DuoTournamentEvent.human_attribute_name("rank.#{duo_name}")
    else
      nil
    end
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'duo-tournament-event' do
      h.content_tag :div, class: :name do
        name
      end
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

  def first_duo_tournament_event_link(options = {})
    duo_tournament_event = first_duo_tournament_event
    if duo_tournament_event
      duo_tournament_event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

  def previous_duo_tournament_event_link(options = {})
    duo_tournament_event = previous_duo_tournament_event
    if duo_tournament_event
      duo_tournament_event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

  def next_duo_tournament_event_link(options = {})
    duo_tournament_event = next_duo_tournament_event
    if duo_tournament_event
      duo_tournament_event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

  def last_duo_tournament_event_link(options = {})
    duo_tournament_event = last_duo_tournament_event
    if duo_tournament_event
      duo_tournament_event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

end
