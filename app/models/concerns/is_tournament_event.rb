module IsTournamentEvent
  extend ActiveSupport::Concern

  included do
    # ---------------------------------------------------------------------------
    # RELATIONS
    # ---------------------------------------------------------------------------

    belongs_to :recurring_tournament, optional: true
    belongs_to :bracket, polymorphic: true, optional: true

    has_many :met_reward_conditions, as: :event, dependent: :destroy

    has_one_attached :graph

    # ---------------------------------------------------------------------------
    # VALIDATIONS
    # ---------------------------------------------------------------------------

    validates :bracket_id,
              uniqueness: {
                scope: :bracket_type,
                allow_nil: true
              }
    validates :name, presence: true
    validates :date, presence: true
    validates :graph, content_type: %r{\Aimage/.*\z}

    # ---------------------------------------------------------------------------
    # CALLBACKS
    # ---------------------------------------------------------------------------

    after_commit :compute_rewards, if: :persisted?

    # ---------------------------------------------------------------------------
    # SCOPES
    # ---------------------------------------------------------------------------

    def self.with_missing_graph
      where(
        is_complete: false
      ).where.not(
        id: ActiveStorage::Attachment.where(
          record_type: to_s
        ).select(:record_id)
      )
    end

    def self.with_missing_data
      where(
        is_complete: false
      ).where(
        "date < '2018-12-07' OR participants_count IS NULL OR participants_count = 0"
      )
    end

    scope :on_smashgg, -> { where("bracket_url LIKE 'https://smash.gg/%'") }
    scope :on_braacket, -> { where("bracket_url LIKE 'https://braacket.com/%'") }
    scope :on_challonge, -> { where("bracket_url LIKE 'https://challonge.com/%'") }
    scope :on_platform, -> { on_smashgg.or(on_braacket).or(on_challonge) }
    scope :with_available_bracket, -> { on_platform.where(bracket: nil) }

    def self.by_bracket_type(val)
      where(bracket_type: val)
    end

    def self.by_bracket_id(val)
      where(bracket_id: val)
    end

    def self.on_year(year)
      date_min = Date.new(year, 1, 1)
      date_max = Date.new(year, 12, 31)
      where('date BETWEEN ? AND ?', date_min, date_max)
    end

    scope :with_recurring_tournament, -> { where.not(recurring_tournament_id: nil) }
    scope :without_recurring_tournament, -> { where(recurring_tournament_id: nil) }

    def self.online
      with_recurring_tournament.where(
        recurring_tournament_id: RecurringTournament.online.select(:id)
      ).or(
        without_recurring_tournament.where(is_online: true)
      )
    end

    def self.offline
      where.not(id: online.select(:id))
    end

    def self.visible
      without_recurring_tournament.or(
        with_recurring_tournament.where(
          recurring_tournament_id: RecurringTournament.visible.select(:id)
        )
      )
    end

    def self.hidden
      with_recurring_tournament.where(
        recurring_tournament_id: RecurringTournament.hidden.select(:id)
      )
    end

    # ---------------------------------------------------------------------------
    # HELPERS
    # ---------------------------------------------------------------------------

    def online?
      if recurring_tournament
        recurring_tournament.is_online?
      else
        is_online?
      end
    end

    def offline?
      !online?
    end

    def bracket_gid
      bracket&.to_global_id&.to_s
    end

    def bracket_gid=(gid)
      self.bracket = GlobalID::Locator.locate gid
    end

    def self.bracket_autocomplete(term)
      searchable_types = [BraacketTournament, ChallongeTournament, SmashggEvent].map(&:to_s)

      {
        results: PgSearch.multisearch(term).where(
          searchable_type: searchable_types
        ).map do |document|
          model = document.searchable.decorate
          {
            id: model.to_global_id.to_s,
            text: [
              model.autocomplete_name,
              model.start_at&.to_date
            ].join("\n")
          }
        end
      }
    end

    def first_event
      return nil if recurring_tournament.nil?

      result = recurring_tournament_events.order(:date).first
      return nil if result.id == id

      result
    end

    def previous_event
      return nil if recurring_tournament.nil?

      recurring_tournament_events.where(
        'date < ? OR (date = ? AND name < ?)', date, date, name
      ).order(date: :desc).first
    end

    def next_event
      return nil if recurring_tournament.nil?

      recurring_tournament_events.where(
        'date > ? OR (date = ? AND name > ?)', date, date, name
      ).order(:date).first
    end

    def last_event
      return nil if recurring_tournament.nil?

      result = recurring_tournament_events.order(:date).last
      return nil if result.id == id

      result
    end

    def compute_rewards
      ids = []

      if !is_out_of_ranking? && (participants_count || 0) > 0
        reward_conditions = RewardCondition.by_is_online(
          online?
        ).by_is_duo(
          duo?
        ).for_size(
          participants_count
        )

        self.class::TOP_NAMES.each do |top_name|
          top = send(top_name)
          next if top.nil?

          reward_condition = reward_conditions.by_rank(
            self.class::TOP_NAME_RANK[top_name]
          ).first
          next if reward_condition.nil?

          ids << MetRewardCondition.where(
            awarded: top,
            event: self,
            reward_condition: reward_condition
          ).first_or_create!.id
        end
      end

      met_reward_conditions.where.not(id: ids).destroy_all
    end

    def self.compute_all_rewards
      find_each(&:compute_rewards)
    end

    delegate :name,
             to: :recurring_tournament,
             prefix: true,
             allow_nil: true

    def is_on_smashgg?
      if !bracket_type.nil?
        bracket_type.to_sym == :SmashggEvent
      else
        bracket_url&.starts_with?('https://smash.gg/')
      end
    end

    def is_on_braacket?
      bracket_type.nil? && bracket_url&.starts_with?('https://braacket.com/')
    end

    def is_on_challonge?
      if !bracket_type.nil?
        bracket_type.to_sym == :ChallongeTournament
      else
        bracket_url&.starts_with?('https://challonge.com/')
      end
    end

    def update_smashgg_event
      return false unless is_on_smashgg?

      if bracket.nil? || !bracket.is_a?(SmashggEvent)
        self.bracket = SmashggEvent.from_url(bracket_url)
        unless bracket
          Rails.logger.debug "Unable to find SmashggEvent: #{bracket_url}"
          return false
        end
      else
        bracket.fetch_smashgg_data
      end
      unless bracket.save
        Rails.logger.debug "Unable to save SmashggEvent: #{bracket.errors.full_messages}"
        return false
      end
      true
    end

    def update_braacket_tournament
      return false unless is_on_braacket?

      if bracket.nil? || !bracket.is_a?(BraacketTournament)
        self.bracket = BraacketTournament.from_url(bracket_url)
      else
        bracket.fetch_braacket_data
      end
      unless bracket.save
        Rails.logger.debug "Unable to save BraacketTournament: #{bracket.errors.full_messages}"
        return false
      end
      Rails.logger.debug 'Successfully updated BraacketTournament'
      true
    end

    def update_challonge_tournament
      return false unless is_on_challonge?

      if bracket.nil? || !bracket.is_a?(ChallongeTournament)
        self.bracket = ChallongeTournament.from_url(bracket_url)
      else
        bracket.fetch_challonge_data
      end
      unless bracket.save
        Rails.logger.debug "Unable to save ChallongeTournament: #{bracket.errors.full_messages}"
        return false
      end
      Rails.logger.debug 'Successfully updated ChallongeTournament'
      true
    end

    def update_bracket
      return update_smashgg_event if is_on_smashgg?
      return update_braacket_tournament if is_on_braacket?
      return update_challonge_tournament if is_on_challonge?

      false
    end

    def complete_with_smashgg
      update_smashgg_event && use_smashgg_event(false)
    end

    def complete_with_braacket
      update_braacket_tournament && use_braacket_tournament(false)
    end

    def complete_with_challonge
      update_challonge_tournament && use_challonge_tournament(false)
    end

    def complete_with_bracket
      return complete_with_smashgg if is_on_smashgg?
      return complete_with_braacket if is_on_braacket?
      return complete_with_challonge if is_on_challonge?

      false
    end

    def update_with_smashgg
      update_smashgg_event && use_smashgg_event(true) && save
    end

    def update_with_braacket
      update_braacket_tournament && use_braacket_tournament(true) && save
    end

    def update_with_challonge
      update_challonge_tournament && use_challonge_tournament(true) && save
    end

    def update_with_bracket
      return update_with_smashgg if is_on_smashgg?
      return update_with_braacket if is_on_braacket?
      return update_with_challonge if is_on_challonge?

      false
    end

    def self.update_available_brackets
      with_available_bracket.order(id: :desc).find_each do |event|
        event.update_bracket && event.save
      end
    end

    def graph_url
      return nil unless graph.attached?

      graph.service_url
    end

    def graph_url=(url)
      uri = URI.parse(url)
      open(url) do |f|
        graph.attach(io: File.open(f.path), filename: File.basename(uri.path))
      end
    end

    # ---------------------------------------------------------------------------
    # GLOBAL SEARCH
    # ---------------------------------------------------------------------------

    include PgSearch::Model
    multisearchable against: %i[name]

    # ---------------------------------------------------------------------------
    # VERSIONS
    # ---------------------------------------------------------------------------

    has_paper_trail unless: proc { ENV['NO_PAPERTRAIL'] }
  end
end
