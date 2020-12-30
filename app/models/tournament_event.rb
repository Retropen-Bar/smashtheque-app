# == Schema Information
#
# Table name: tournament_events
#
#  id                      :bigint           not null, primary key
#  bracket_url             :string
#  date                    :date             not null
#  is_complete             :boolean          default(FALSE), not null
#  name                    :string           not null
#  participants_count      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  recurring_tournament_id :bigint
#  smashgg_event_id        :bigint
#  top1_player_id          :bigint
#  top2_player_id          :bigint
#  top3_player_id          :bigint
#  top4_player_id          :bigint
#  top5a_player_id         :bigint
#  top5b_player_id         :bigint
#  top7a_player_id         :bigint
#  top7b_player_id         :bigint
#
# Indexes
#
#  index_tournament_events_on_recurring_tournament_id  (recurring_tournament_id)
#  index_tournament_events_on_smashgg_event_id         (smashgg_event_id)
#  index_tournament_events_on_top1_player_id           (top1_player_id)
#  index_tournament_events_on_top2_player_id           (top2_player_id)
#  index_tournament_events_on_top3_player_id           (top3_player_id)
#  index_tournament_events_on_top4_player_id           (top4_player_id)
#  index_tournament_events_on_top5a_player_id          (top5a_player_id)
#  index_tournament_events_on_top5b_player_id          (top5b_player_id)
#  index_tournament_events_on_top7a_player_id          (top7a_player_id)
#  index_tournament_events_on_top7b_player_id          (top7b_player_id)
#
# Foreign Keys
#
#  fk_rails_...  (recurring_tournament_id => recurring_tournaments.id)
#  fk_rails_...  (smashgg_event_id => smashgg_events.id)
#  fk_rails_...  (top1_player_id => players.id)
#  fk_rails_...  (top2_player_id => players.id)
#  fk_rails_...  (top3_player_id => players.id)
#  fk_rails_...  (top4_player_id => players.id)
#  fk_rails_...  (top5a_player_id => players.id)
#  fk_rails_...  (top5b_player_id => players.id)
#  fk_rails_...  (top7a_player_id => players.id)
#  fk_rails_...  (top7b_player_id => players.id)
#
class TournamentEvent < ApplicationRecord

  PLAYER_RANKS = %w(1 2 3 4 5a 5b 7a 7b).freeze
  PLAYER_NAMES = PLAYER_RANKS.map{|rank| "top#{rank}_player".to_sym}.freeze
  PLAYER_NAME_RANK = Hash[
    PLAYER_RANKS.map do |rank|
      [
        "top#{rank}_player".to_sym,
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
  belongs_to :top1_player, class_name: :Player, optional: true
  belongs_to :top2_player, class_name: :Player, optional: true
  belongs_to :top3_player, class_name: :Player, optional: true
  belongs_to :top4_player, class_name: :Player, optional: true
  belongs_to :top5a_player, class_name: :Player, optional: true
  belongs_to :top5b_player, class_name: :Player, optional: true
  belongs_to :top7a_player, class_name: :Player, optional: true
  belongs_to :top7b_player, class_name: :Player, optional: true
  belongs_to :smashgg_event, optional: true

  has_one_attached :graph

  has_many :player_reward_conditions, dependent: :destroy

  # ---------------------------------------------------------------------------
  # validations
  # ---------------------------------------------------------------------------

  validates :smashgg_event,
            uniqueness: {
              allow_nil: true
            }
  validates :name, presence: true
  validates :date, presence: true
  validates :graph, content_type: /\Aimage\/.*\z/
  validate :unique_players

  def unique_players
    _player_ids = player_ids
    duplicate = PLAYER_NAMES.reverse.find do |player_name|
      player_id = send(player_name)
      player_id && _player_ids.count(player_id) > 1
    end
    if duplicate
      original = PLAYER_NAMES.find do |player_name|
        send(player_name) == send(duplicate)
      end
      errors.add(
        duplicate,
        TournamentEvent.human_attribute_name(original)
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

  def self.with_missing_players
    where(
      is_complete: false
    ).where(
      PLAYER_NAMES.map do |player_name|
        "#{player_name}_id IS NULL"
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

  def self.with_player(player_id)
    where(
      PLAYER_NAMES.map do |player_name|
        "#{player_name}_id = ?"
      end.join(" OR "),
      *PLAYER_NAMES.map { player_id }
    )
  end

  scope :on_smashgg, -> { where("bracket_url LIKE 'https://smash.gg/%'") }
  scope :on_braacket, -> { where("bracket_url LIKE 'https://braacket.com/%'") }
  scope :on_challonge, -> { where("bracket_url LIKE 'https://challonge.com/%'") }

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def player_ids
    PLAYER_NAMES.map do |player_name|
      send(player_name)
    end.compact
  end

  def previous_tournament_event
    return nil if recurring_tournament.nil?
    recurring_tournament.tournament_events
                        .where("date < ? OR (date = ? AND name < ?)", date, date, name)
                        .order(date: :desc)
                        .first
  end

  def next_tournament_event
    return nil if recurring_tournament.nil?
    recurring_tournament.tournament_events
                        .where("date > ? OR (date = ? AND name > ?)", date, date, name)
                        .order(:date)
                        .first
  end

  def compute_rewards
    ids = []

    if (participants_count || 0) > 0
      reward_conditions = RewardCondition.for_size(participants_count)
      PLAYER_NAMES.each do |player_name|
        if player = send(player_name)
          reward_condition = reward_conditions.by_rank(
            PLAYER_NAME_RANK[player_name]
          ).first
          if reward_condition
            ids << PlayerRewardCondition.where(
              player: player,
              tournament_event: self,
              reward_condition: reward_condition
            ).first_or_create!.id
          end
        end
      end
    end

    player_reward_conditions.where.not(id: ids).destroy_all
  end

  def self.compute_all_rewards
    find_each(&:compute_rewards)
  end

  def as_json(options = {})
    super(options.merge(
      methods: %i(
        recurring_tournament_name
        top1_player_name
        top2_player_name
        top3_player_name
        top4_player_name
        top5a_player_name
        top5b_player_name
        top7a_player_name
        top7b_player_name
        graph_url
      )
    ))
  end

  delegate :name,
           to: :recurring_tournament,
           prefix: true

  PLAYER_NAMES.each do |player_name|
    delegate :name,
             to: player_name,
             prefix: true,
             allow_nil: true
  end

  def is_on_smashgg?
    bracket_url&.starts_with?('https://smash.gg/')
  end
  def is_on_braacket?
    bracket_url&.starts_with?('https://braacket.com/')
  end
  def is_on_challonge?
    bracket_url&.starts_with?('https://challonge.com/')
  end

  def use_smashgg_event(replace_existing_values)
    return false if smashgg_event.nil?
    if replace_existing_values || name.blank?
      self.name = smashgg_event.tournament_name
    end
    if replace_existing_values || date.nil?
      self.date = smashgg_event.start_at
    end
    if replace_existing_values || participants_count.nil?
      self.participants_count = smashgg_event.num_entrants
    end
    if replace_existing_values || bracket_url.blank?
      self.bracket_url = smashgg_event.smashgg_url
    end
    PLAYER_RANKS.each do |rank|
      player_name = "top#{rank}_player".to_sym
      user_name = "top#{rank}_smashgg_user".to_sym
      if replace_existing_values || send(player_name).nil?
        if player = smashgg_event.send(user_name)&.player
          self.send("#{player_name}=", player)
        end
      end
    end
    true
  end

  def update_smashgg_event
    return false unless is_on_smashgg?
    if smashgg_event.nil?
      self.smashgg_event = SmashggEvent.from_url(bracket_url)
    else
      smashgg_event.fetch_smashgg_data
    end
    unless smashgg_event.save
      puts "Unable to save SmashggEvent: #{smashgg_event.errors.full_messages}"
      return false
    end
    true
  end

  def complete_with_smashgg
    update_smashgg_event && use_smashgg_event(false)
  end

  def complete_with_braacket
    false
  end

  def complete_with_challonge
    false
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
    false
  end

  def update_with_bracket
    return update_with_smashgg if is_on_smashgg?
    return update_with_braacket if is_on_braacket?
    return update_with_challonge if is_on_challonge?
    false
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
