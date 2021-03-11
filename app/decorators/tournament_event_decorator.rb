class TournamentEventDecorator < TournamentEventBaseDecorator

  def player_rank(player_id)
    TournamentEvent::PLAYER_NAMES.each do |player_name|
      return player_name if send("#{player_name}_id") == player_id
    end
    nil
  end

  def player_rank_name(player_id)
    player_name = player_rank(player_id)
    if player_name
      TournamentEvent.human_attribute_name("rank.#{player_name}")
    else
      nil
    end
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'tournament-event' do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

  TournamentEvent::PLAYER_RANKS.each do |rank|
    player_name = "top#{rank}_player".to_sym
    define_method "#{player_name}_bracket_suggestion" do
      return nil if bracket.nil?
      case bracket_type.to_sym
      when :SmashggEvent
        user_name = "top#{rank}_smashgg_user".to_sym
        [
          'Bracket smash.gg',
          bracket.send(user_name)&.gamer_tag
        ].join(' : ')
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

  def first_tournament_event_link(options = {})
    tournament_event = first_tournament_event
    if tournament_event
      tournament_event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

  def previous_tournament_event_link(options = {})
    tournament_event = previous_tournament_event
    if tournament_event
      tournament_event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

  def next_tournament_event_link(options = {})
    tournament_event = next_tournament_event
    if tournament_event
      tournament_event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

  def last_tournament_event_link(options = {})
    tournament_event = last_tournament_event
    if tournament_event
      tournament_event.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end

end
