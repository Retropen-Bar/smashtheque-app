# == Schema Information
#
# Table name: duo_tournament_events
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
  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include IsTournamentEvent

  def recurring_tournament_events
    recurring_tournament.duo_tournament_events
  end

  def duo?
    true
  end

  # ---------------------------------------------------------------------------
  # CONSTANTS
  # ---------------------------------------------------------------------------

  TOP_NAMES = TournamentEvent::TOP_RANKS.map { |rank| "top#{rank}_duo".to_sym }.freeze
  TOP_NAME_RANK = TournamentEvent::TOP_RANKS.map do |rank|
    [
      "top#{rank}_duo".to_sym,
      case rank
      when '5a', '5b' then 5
      when '7a', '7b' then 7
      else rank.to_i
      end
    ]
  end.to_h.freeze

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :top1_duo, class_name: :Duo, optional: true
  belongs_to :top2_duo, class_name: :Duo, optional: true
  belongs_to :top3_duo, class_name: :Duo, optional: true
  belongs_to :top4_duo, class_name: :Duo, optional: true
  belongs_to :top5a_duo, class_name: :Duo, optional: true
  belongs_to :top5b_duo, class_name: :Duo, optional: true
  belongs_to :top7a_duo, class_name: :Duo, optional: true
  belongs_to :top7b_duo, class_name: :Duo, optional: true

  # ---------------------------------------------------------------------------
  # validations
  # ---------------------------------------------------------------------------

  validate :unique_duos

  def unique_duos
    all_duo_ids = duo_ids
    duplicate = TOP_NAMES.reverse.find do |duo_name|
      duo_id = send(duo_name)
      duo_id && all_duo_ids.count(duo_id) > 1
    end
    return unless duplicate

    original = TOP_NAMES.find do |duo_name|
      send(duo_name) == send(duplicate)
    end
    errors.add(
      duplicate,
      DuoTournamentEvent.human_attribute_name(original)
    )
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.with_missing_duos
    where(
      is_complete: false
    ).where(
      TOP_NAMES.map do |duo_name|
        "#{duo_name}_id IS NULL"
      end.join(' OR ')
    )
  end

  def self.with_duo(duo_id)
    where(
      TOP_NAMES.map do |duo_name|
        "#{duo_name}_id = ?"
      end.join(' OR '),
      *TOP_NAMES.map { duo_id }
    )
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def duo_ids
    TOP_NAMES.map do |duo_name|
      send(duo_name)
    end.compact
  end

  def as_json(options = {})
    super(options.merge(
      methods: %i[
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
      ]
    ))
  end

  TOP_NAMES.each do |duo_name|
    delegate :name,
             to: duo_name,
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
    # TournamentEvent::TOP_RANKS.each do |rank|
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
end
