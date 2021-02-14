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
