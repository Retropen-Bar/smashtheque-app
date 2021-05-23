class TournamentEventDecorator < TournamentEventBaseDecorator
  def player_rank(player_id)
    TournamentEvent::PLAYER_NAMES.each do |player_name|
      return player_name if send("#{player_name}_id") == player_id
    end
    nil
  end

  def player_rank_name(player_id)
    player_name = player_rank(player_id)
    TournamentEvent.human_attribute_name("rank.#{player_name}") if player_name
  end

  def as_autocomplete_result
    h.tag.div class: 'tournament-event' do
      h.tag.div class: :name do
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
        [
          'Bracket smash.gg',
          bracket.send("top#{rank}_smashgg_user".to_sym)&.gamer_tag
        ].join(' : ')
      when :BraacketTournament
        [
          'Bracket Braacket',
          bracket.send("top#{rank}_participant_name".to_sym)
        ].join(' : ')
      when :ChallongeTournament
        [
          'Bracket Challonge',
          bracket.send("top#{rank}_participant_name".to_sym)
        ].join(' : ')
      end
    end
  end
end
