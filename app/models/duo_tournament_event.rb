# == Schema Information
#
# Table name: duo_tournament_events
#
#  id                      :bigint           not null, primary key
#  bracket_type            :string
#  bracket_url             :string
#  date                    :date             not null
#  is_complete             :boolean          default(FALSE), not null
#  is_out_of_ranking       :boolean          default(FALSE), not null
#  name                    :string           not null
#  participants_count      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  bracket_id              :bigint
#  recurring_tournament_id :bigint           not null
#  top1_duo_id             :bigint
#  top2_duo_id             :bigint
#  top3_duo_id             :bigint
#  top4_duo_id             :bigint
#  top5a_duo_id            :bigint
#  top5b_duo_id            :bigint
#  top7a_duo_id            :bigint
#  top7b_duo_id            :bigint
#
# Indexes
#
#  index_duo_tournament_events_on_bracket_type_and_bracket_id  (bracket_type,bracket_id)
#  index_duo_tournament_events_on_recurring_tournament_id      (recurring_tournament_id)
#  index_duo_tournament_events_on_top1_duo_id                  (top1_duo_id)
#  index_duo_tournament_events_on_top2_duo_id                  (top2_duo_id)
#  index_duo_tournament_events_on_top3_duo_id                  (top3_duo_id)
#  index_duo_tournament_events_on_top4_duo_id                  (top4_duo_id)
#  index_duo_tournament_events_on_top5a_duo_id                 (top5a_duo_id)
#  index_duo_tournament_events_on_top5b_duo_id                 (top5b_duo_id)
#  index_duo_tournament_events_on_top7a_duo_id                 (top7a_duo_id)
#  index_duo_tournament_events_on_top7b_duo_id                 (top7b_duo_id)
#
# Foreign Keys
#
#  fk_rails_...  (recurring_tournament_id => recurring_tournaments.id)
#  fk_rails_...  (top1_duo_id => duos.id)
#  fk_rails_...  (top2_duo_id => duos.id)
#  fk_rails_...  (top3_duo_id => duos.id)
#  fk_rails_...  (top4_duo_id => duos.id)
#  fk_rails_...  (top5a_duo_id => duos.id)
#  fk_rails_...  (top5b_duo_id => duos.id)
#  fk_rails_...  (top7a_duo_id => duos.id)
#  fk_rails_...  (top7b_duo_id => duos.id)
#
class DuoTournamentEvent < ApplicationRecord

  DUO_NAMES = TournamentEvent::PLAYER_RANKS.map{|rank| "top#{rank}_duo".to_sym}.freeze
  DUO_NAME_RANK = Hash[
    TournamentEvent::PLAYER_RANKS.map do |rank|
      [
        "top#{rank}_duo".to_sym,
        case rank
        when '5a', '5b' then 5
        when '7a', '7b' then 7
        else rank.to_i
        end
      ]
    end
  ].freeze

  # ---------------------------------------------------------------------------
  # relations
  # ---------------------------------------------------------------------------

  belongs_to :recurring_tournament
  belongs_to :top1_duo, class_name: :Duo, optional: true
  belongs_to :top2_duo, class_name: :Duo, optional: true
  belongs_to :top3_duo, class_name: :Duo, optional: true
  belongs_to :top4_duo, class_name: :Duo, optional: true
  belongs_to :top5a_duo, class_name: :Duo, optional: true
  belongs_to :top5b_duo, class_name: :Duo, optional: true
  belongs_to :top7a_duo, class_name: :Duo, optional: true
  belongs_to :top7b_duo, class_name: :Duo, optional: true
  belongs_to :bracket, polymorphic: true, optional: true

  has_one_attached :graph

  has_many :duo_reward_duo_conditions, dependent: :destroy

  # ---------------------------------------------------------------------------
  # validations
  # ---------------------------------------------------------------------------

  validates :bracket_id,
            uniqueness: {
              scope: :bracket_type,
              allow_nil: true
            }
  validates :name, presence: true
  validates :date, presence: true
  validates :graph, content_type: /\Aimage\/.*\z/
  validate :unique_duos

  def unique_duos
    _duo_ids = duo_ids
    duplicate = DUO_NAMES.reverse.find do |duo_name|
      duo_id = send(duo_name)
      duo_id && _duo_ids.count(duo_id) > 1
    end
    if duplicate
      original = DUO_NAMES.find do |duo_name|
        send(duo_name) == send(duplicate)
      end
      errors.add(
        duplicate,
        DuoTournamentEvent.human_attribute_name(original)
      )
    end
  end

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
      id: ActiveStorage::Attachment.where(record_type: TournamentEvent.to_s)
                                   .select(:record_id)
    )
  end

  def self.with_missing_duos
    where(
      is_complete: false
    ).where(
      DUO_NAMES.map do |duo_name|
        "#{duo_name}_id IS NULL"
      end.join(" OR ")
    )
  end

  def self.with_missing_data
    where(
      is_complete: false
    ).where(
      "date < '2018-12-07' OR participants_count IS NULL OR participants_count = 0"
    )
  end

  def self.with_duo(duo_id)
    where(
      DUO_NAMES.map do |duo_name|
        "#{duo_name}_id = ?"
      end.join(" OR "),
      *DUO_NAMES.map { duo_id }
    )
  end

  scope :on_smashgg, -> { where("bracket_url LIKE 'https://smash.gg/%'") }
  scope :on_braacket, -> { where("bracket_url LIKE 'https://braacket.com/%'") }
  scope :on_challonge, -> { where("bracket_url LIKE 'https://challonge.com/%'") }
  scope :on_platform, -> { on_smashgg.or(on_braacket).or(on_challonge) }
  scope :with_available_bracket, -> { on_platform.where(bracket: nil) }

  def self.by_bracket_type(v)
    where(bracket_type: v)
  end

  def self.by_bracket_id(v)
    where(bracket_id: v)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def bracket_gid
    self.bracket&.to_global_id&.to_s
  end

  def bracket_gid=(gid)
    self.bracket = GlobalID::Locator.locate gid
  end

  def self.bracket_autocomplete(term)
    searchable_types = [ChallongeTournament, SmashggEvent].map(&:to_s)

    {
      results: PgSearch.multisearch(term).where(searchable_type: searchable_types).map do |document|
        model = document.searchable.decorate
        {
          id: model.to_global_id.to_s,
          text: model.decorate.autocomplete_name
        }
      end
    }
  end

  def duo_ids
    DUO_NAMES.map do |duo_name|
      send(duo_name)
    end.compact
  end

  def previous_duo_tournament_event
    return nil if recurring_tournament.nil?
    recurring_tournament.duo_tournament_events
                        .where("date < ? OR (date = ? AND name < ?)", date, date, name)
                        .order(date: :desc)
                        .first
  end

  def next_duo_tournament_event
    return nil if recurring_tournament.nil?
    recurring_tournament.duo_tournament_events
                        .where("date > ? OR (date = ? AND name > ?)", date, date, name)
                        .order(:date)
                        .first
  end

  def compute_rewards
    ids = []

    if (participants_count || 0) > 0
      reward_duo_conditions = RewardDuoCondition.for_size(participants_count)
      DUO_NAMES.each do |duo_name|
        if duo = send(duo_name)
          reward_duo_condition = reward_duo_conditions.by_rank(
            DUO_NAME_RANK[duo_name]
          ).first
          if reward_duo_condition
            ids << DuoRewardDuoCondition.where(
              duo: duo,
              duo_tournament_event: self,
              reward_duo_condition: reward_duo_condition
            ).first_or_create!.id
          end
        end
      end
    end

    duo_reward_duo_conditions.where.not(id: ids).destroy_all
  end

  def self.compute_all_rewards
    find_each(&:compute_rewards)
  end

  def as_json(options = {})
    super(options.merge(
      methods: %i(
        recurring_tournament_name
        top1_duo_name
        top2_duo_name
        top3_duo_name
        top4_duo_name
        top5a_duo_name
        top5b_duo_name
        top7a_duo_name
        top7b_duo_name
        graph_url
      )
    ))
  end

  delegate :name,
           to: :recurring_tournament,
           prefix: true

  DUO_NAMES.each do |duo_name|
    delegate :name,
             to: duo_name,
             prefix: true,
             allow_nil: true
  end

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

  def use_smashgg_event(replace_existing_values)
    return false unless bracket.is_a?(SmashggEvent)
    if replace_existing_values || name.blank?
      self.name = bracket.tournament_name
    end
    if replace_existing_values || date.nil?
      self.date = bracket.start_at
    end
    if replace_existing_values || participants_count.nil?
      self.participants_count = bracket.num_entrants
    end
    if replace_existing_values || bracket_url.blank?
      self.bracket_url = bracket.smashgg_url
    end
    # TournamentEvent::PLAYER_RANKS.each do |rank|
    #   duo_name = "top#{rank}_duo".to_sym
    #   user_name = "top#{rank}_smashgg_duo".to_sym
    #   if replace_existing_values || send(duo_name).nil?
    #     if duo = bracket.send(user_name)&.duo
    #       self.send("#{duo_name}=", duo)
    #     end
    #   end
    # end
    true
  end

  def use_challonge_tournament(replace_existing_values)
    return false unless bracket.is_a?(ChallongeTournament)
    if replace_existing_values || name.blank?
      self.name = bracket.name
    end
    if replace_existing_values || date.nil?
      self.date = bracket.start_at
    end
    if replace_existing_values || participants_count.nil?
      self.participants_count = bracket.participants_count
    end
    if replace_existing_values || bracket_url.blank?
      self.bracket_url = bracket.challonge_url
    end
    true
  end

  def update_smashgg_event
    return false unless is_on_smashgg?
    if bracket.nil? || !bracket.is_a?(SmashggEvent)
      self.bracket = SmashggEvent.from_url(bracket_url)
    else
      bracket.fetch_smashgg_data
    end
    unless bracket.save
      puts "Unable to save SmashggEvent: #{bracket.errors.full_messages}"
      return false
    end
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
      puts "Unable to save ChallongeTournament: #{bracket.errors.full_messages}"
      return false
    end
    puts 'Successfully updated ChallongeTournament'
    true
  end

  def update_bracket
    return update_smashgg_event if is_on_smashgg?
    return update_challonge_tournament if is_on_challonge?
    false
  end

  def complete_with_smashgg
    update_smashgg_event && use_smashgg_event(false)
  end

  def complete_with_braacket
    false
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
    false
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
    with_available_bracket.order(id: :desc).find_each do |tournament_event|
      tournament_event.update_bracket && tournament_event.save
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
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i(name)

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
