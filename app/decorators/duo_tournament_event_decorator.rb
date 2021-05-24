class DuoTournamentEventDecorator < TournamentEventBaseDecorator
  def duo_rank(duo_id)
    DuoTournamentEvent::TOP_NAMES.each do |duo_name|
      return duo_name if send("#{duo_name}_id") == duo_id
    end
    nil
  end

  def duo_rank_name(duo_id)
    duo_name = duo_rank(duo_id)
    DuoTournamentEvent.human_attribute_name("rank.#{duo_name}") if duo_name
  end

  def as_autocomplete_result
    h.tag.div class: 'duo-tournament-event' do
      h.tag.div class: :name do
        name
      end
    end
  end

  TournamentEvent::TOP_RANKS.each do |rank|
    duo_name = "top#{rank}_duo".to_sym
    define_method "#{duo_name}_bracket_suggestion" do
      return nil if bracket.nil?

      case bracket_type.to_sym
      when :ChallongeTournament
        participant_name = "top#{rank}_participant_name".to_sym
        [
          'Bracket Challonge',
          bracket.send(participant_name)
        ].join(' : ')
      end
    end
  end
end
