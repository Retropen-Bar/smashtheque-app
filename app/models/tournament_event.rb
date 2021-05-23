# == Schema Information
#
# Table name: tournament_events
#
#  id                      :bigint           not null, primary key
#  bracket_type            :string
#  bracket_url             :string
#  date                    :date             not null
#  is_complete             :boolean          default(FALSE), not null
#  is_online               :boolean          default(FALSE), not null
#  is_out_of_ranking       :boolean          default(FALSE), not null
#  name                    :string           not null
#  participants_count      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  bracket_id              :bigint
#  recurring_tournament_id :integer
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
#  index_tournament_events_on_bracket_type_and_bracket_id  (bracket_type,bracket_id)
#  index_tournament_events_on_recurring_tournament_id      (recurring_tournament_id)
#  index_tournament_events_on_top1_player_id               (top1_player_id)
#  index_tournament_events_on_top2_player_id               (top2_player_id)
#  index_tournament_events_on_top3_player_id               (top3_player_id)
#  index_tournament_events_on_top4_player_id               (top4_player_id)
#  index_tournament_events_on_top5a_player_id              (top5a_player_id)
#  index_tournament_events_on_top5b_player_id              (top5b_player_id)
#  index_tournament_events_on_top7a_player_id              (top7a_player_id)
#  index_tournament_events_on_top7b_player_id              (top7b_player_id)
#
# Foreign Keys
#
#  fk_rails_...  (recurring_tournament_id => recurring_tournaments.id)
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
  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include IsTournamentEvent
  def recurring_tournament_events
    recurring_tournament.tournament_events
  end

  # ---------------------------------------------------------------------------
  # CONSTANTS
  # ---------------------------------------------------------------------------

  PLAYER_RANKS = %w[1 2 3 4 5a 5b 7a 7b].freeze
  PLAYER_NAMES = PLAYER_RANKS.map { |rank| "top#{rank}_player".to_sym }.freeze
  PLAYER_NAME_RANK = PLAYER_RANKS.map do |rank|
    [
      "top#{rank}_player".to_sym,
      case rank
      when '5a', '5b' then 5
      when '7a', '7b' then 7
      else rank.to_i
      end
    ]
  end.to_h.freeze

  # ---------------------------------------------------------------------------
  # relations
  # ---------------------------------------------------------------------------

  belongs_to :top1_player, class_name: :Player, optional: true
  belongs_to :top2_player, class_name: :Player, optional: true
  belongs_to :top3_player, class_name: :Player, optional: true
  belongs_to :top4_player, class_name: :Player, optional: true
  belongs_to :top5a_player, class_name: :Player, optional: true
  belongs_to :top5b_player, class_name: :Player, optional: true
  belongs_to :top7a_player, class_name: :Player, optional: true
  belongs_to :top7b_player, class_name: :Player, optional: true

  has_many :player_reward_conditions, dependent: :destroy

  # ---------------------------------------------------------------------------
  # validations
  # ---------------------------------------------------------------------------

  validate :unique_players

  def unique_players
    all_player_ids = player_ids
    duplicate = PLAYER_NAMES.reverse.find do |player_name|
      player_id = send(player_name)
      player_id && all_player_ids.count(player_id) > 1
    end
    return unless duplicate

    original = PLAYER_NAMES.find do |player_name|
      send(player_name) == send(duplicate)
    end
    errors.add(
      duplicate,
      TournamentEvent.human_attribute_name(original)
    )
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.with_missing_players
    where(
      is_complete: false
    ).where(
      PLAYER_NAMES.map do |player_name|
        "#{player_name}_id IS NULL"
      end.join(' OR ')
    )
  end

  def self.with_player(player_id)
    where(
      PLAYER_NAMES.map do |player_name|
        "#{player_name}_id = ?"
      end.join(' OR '),
      *PLAYER_NAMES.map { player_id }
    )
  end

  def self.with_available_players
    # don't return events that have been explicitly marked as complete
    where(
      is_complete: false
    ).by_bracket_type(
      :SmashggEvent
    ).by_bracket_id(
      SmashggEvent.with_available_players.select(:id)
    )
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def player_ids
    PLAYER_NAMES.map do |player_name|
      send(player_name)
    end.compact
  end

  def compute_rewards
    ids = []

    if !is_out_of_ranking? && (participants_count || 0) > 0
      reward_conditions = RewardCondition.by_is_online(online?).for_size(participants_count)
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

  PLAYER_NAMES.each do |player_name|
    delegate :name,
             to: player_name,
             prefix: true,
             allow_nil: true
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
    PLAYER_RANKS.each do |rank|
      player_name = "top#{rank}_player".to_sym
      user_name = "top#{rank}_smashgg_user".to_sym
      if replace_existing_values || send(player_name).nil?
        if player = bracket.send(user_name)&.player
          self.send("#{player_name}=", player)
        end
      end
    end
    true
  end

  def use_braacket_tournament(replace_existing_values)
    return false unless bracket.is_a?(BraacketTournament)

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
      self.bracket_url = bracket.braacket_url
    end
    PLAYER_RANKS.each do |rank|
      player_name = "top#{rank}_player".to_sym
      participant_player = "top#{rank}_participant_player".to_sym
      if replace_existing_values || send(player_name).nil?
        if player = bracket.send(participant_player)
          self.send("#{player_name}=", player)
        end
      end
    end
    true
  end

  def use_challonge_tournament(replace_existing_values)
    return false unless bracket.is_a?(ChallongeTournament)

    self.name = bracket.name if replace_existing_values || name.blank?
    self.date = bracket.start_at if replace_existing_values || date.nil?
    if replace_existing_values || participants_count.nil?
      self.participants_count = bracket.participants_count
    end
    self.bracket_url = bracket.challonge_url if replace_existing_values || bracket_url.blank?
    PLAYER_RANKS.each do |rank|
      player_name = "top#{rank}_player".to_sym
      participant_player = "top#{rank}_participant_player".to_sym
      next unless replace_existing_values || send(player_name).nil?

      if (player = bracket.send(participant_player))
        send("#{player_name}=", player)
      end
    end
    true
  end

  def use_available_bracket_players
    return false if bracket.nil?

    PLAYER_RANKS.each do |rank|
      player_name = "top#{rank}_player".to_sym
      user_name = "top#{rank}_smashgg_user".to_sym
      next unless send(player_name).nil?

      if player = bracket.send(user_name)&.player
        send("#{player_name}=", player)
      end
    end
    true
  end

  def self.use_available_players
    with_available_players.order(id: :desc).find_each do |tournament_event|
      if tournament_event.use_available_bracket_players && !tournament_event.save
        Rails.logger.debug "Unable to save TournamentEvent ##{tournament_event.id}:"
        Rails.logger.debug tournament_event.errors.full_messages
      end
    end
  end
end
