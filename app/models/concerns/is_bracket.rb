module IsBracket
  extend ActiveSupport::Concern

  included do
    # ---------------------------------------------------------------------------
    # RELATIONS
    # ---------------------------------------------------------------------------

    has_one :tournament_event, as: :bracket, dependent: :nullify
    has_one :duo_tournament_event, as: :bracket, dependent: :nullify

    # ---------------------------------------------------------------------------
    # CALLBACKS
    # ---------------------------------------------------------------------------

    before_validation :clean_slug
    def clean_slug
      self.slug.strip!
    end

    # ---------------------------------------------------------------------------
    # SCOPES
    # ---------------------------------------------------------------------------

    scope :ignored, -> { where(is_ignored: true) }
    scope :not_ignored, -> { where(is_ignored: false) }

    def self.with_tournament_event
      where(id: TournamentEvent.by_bracket_type(to_s.to_sym).select(:bracket_id))
    end

    def self.without_tournament_event
      where.not(id: TournamentEvent.by_bracket_type(to_s.to_sym).select(:bracket_id))
    end

    def self.with_duo_tournament_event
      where(id: DuoTournamentEvent.by_bracket_type(to_s.to_sym).select(:bracket_id))
    end

    def self.without_duo_tournament_event
      where.not(id: DuoTournamentEvent.by_bracket_type(to_s.to_sym).select(:bracket_id))
    end

    def self.with_any_tournament_event
      with_tournament_event.or(with_duo_tournament_event)
    end

    def self.without_any_tournament_event
      without_tournament_event.without_duo_tournament_event
    end

    # ---------------------------------------------------------------------------
    # HELPERS
    # ---------------------------------------------------------------------------

    def any_tournament_event
      tournament_event || duo_tournament_event
    end
  end
end
