# == Schema Information
#
# Table name: tournament_events
#
#  id                      :bigint           not null, primary key
#  bracket_url             :string
#  date                    :date             not null
#  name                    :string           not null
#  participants_count      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  recurring_tournament_id :bigint
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

  has_one_attached :graph

  # ---------------------------------------------------------------------------
  # validations
  # ---------------------------------------------------------------------------

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
                        .where("date < ?", date)
                        .order(date: :desc)
                        .first
  end

  def next_tournament_event
    return nil if recurring_tournament.nil?
    recurring_tournament.tournament_events
                        .where("date > ?", date)
                        .order(:date)
                        .first
  end

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
