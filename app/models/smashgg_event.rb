# == Schema Information
#
# Table name: smashgg_events
#
#  id                    :bigint           not null, primary key
#  is_online             :boolean
#  name                  :string
#  num_entrants          :integer
#  slug                  :string           not null
#  start_at              :datetime
#  tournament_name       :string
#  tournament_slug       :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  smashgg_id            :integer          not null
#  top1_smashgg_user_id  :bigint
#  top2_smashgg_user_id  :bigint
#  top3_smashgg_user_id  :bigint
#  top4_smashgg_user_id  :bigint
#  top5a_smashgg_user_id :bigint
#  top5b_smashgg_user_id :bigint
#  top7a_smashgg_user_id :bigint
#  top7b_smashgg_user_id :bigint
#  tournament_id         :integer
#
# Indexes
#
#  index_smashgg_events_on_slug                   (slug) UNIQUE
#  index_smashgg_events_on_smashgg_id             (smashgg_id) UNIQUE
#  index_smashgg_events_on_top1_smashgg_user_id   (top1_smashgg_user_id)
#  index_smashgg_events_on_top2_smashgg_user_id   (top2_smashgg_user_id)
#  index_smashgg_events_on_top3_smashgg_user_id   (top3_smashgg_user_id)
#  index_smashgg_events_on_top4_smashgg_user_id   (top4_smashgg_user_id)
#  index_smashgg_events_on_top5a_smashgg_user_id  (top5a_smashgg_user_id)
#  index_smashgg_events_on_top5b_smashgg_user_id  (top5b_smashgg_user_id)
#  index_smashgg_events_on_top7a_smashgg_user_id  (top7a_smashgg_user_id)
#  index_smashgg_events_on_top7b_smashgg_user_id  (top7b_smashgg_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (top1_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top2_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top3_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top4_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top5a_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top5b_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top7a_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top7b_smashgg_user_id => smashgg_users.id)
#
class SmashggEvent < ApplicationRecord

  USER_NAMES = TournamentEvent::PLAYER_RANKS.map do |rank|
    "top#{rank}_smashgg_user".to_sym
  end.freeze
  USER_NAME_RANK = Hash[
    TournamentEvent::PLAYER_RANKS.map do |rank|
      [
        "top#{rank}_smashgg_user".to_sym,
        case rank
        when '5a', '5b' then 5
        when '7a', '7b' then 7
        else rank.to_i
        end
      ]
    end
  ].freeze

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :top1_smashgg_user, class_name: :SmashggUser, optional: true
  belongs_to :top2_smashgg_user, class_name: :SmashggUser, optional: true
  belongs_to :top3_smashgg_user, class_name: :SmashggUser, optional: true
  belongs_to :top4_smashgg_user, class_name: :SmashggUser, optional: true
  belongs_to :top5a_smashgg_user, class_name: :SmashggUser, optional: true
  belongs_to :top5b_smashgg_user, class_name: :SmashggUser, optional: true
  belongs_to :top7a_smashgg_user, class_name: :SmashggUser, optional: true
  belongs_to :top7b_smashgg_user, class_name: :SmashggUser, optional: true

  has_one :tournament_event, as: :bracket, dependent: :nullify

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :smashgg_id, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.with_tournament_event
    where(id: (
      TournamentEvent.by_bracket_type(:SmashggEvent).select(:bracket_id)
    ))
  end
  def self.without_tournament_event
    where.not(id: (
      TournamentEvent.by_bracket_type(:SmashggEvent).select(:bracket_id)
    ))
  end

  def self.with_smashgg_user(smashgg_user_id)
    where(
      USER_NAMES.map do |user_name|
        "#{user_name}_id = ?"
      end.join(" OR "),
      *USER_NAMES.map { smashgg_user_id }
    )
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.slug_from_url(url)
    url.slice(/tournament\/[^\/]+\/event\/[^\/]+/)
  end

  def self.tournament_slug_from_url(url)
    url.slice(/tournament\/[^\/]+/)
  end

  def smashgg_url=(url)
    self.slug = self.class.slug_from_url(url)
    self.tournament_slug = self.class.tournament_slug_from_url(url)
  end

  def self.from_slug(slug)
    o = where(slug: slug).first_or_initialize
    o.fetch_smashgg_data
    o
  end

  def self.from_tournament_slug(tournament_slug)
    o = where(tournament_slug: tournament_slug).first_or_initialize
    o.fetch_smashgg_data
    o
  end

  def self.from_url(url)
    if slug = slug_from_url(url)
      from_slug(slug)
    elsif tournament_slug = tournament_slug_from_url(url)
      from_tournament_slug(tournament_slug)
    else
      nil
    end
  end

  def self.attributes_from_event_data(data)
    result = {
      smashgg_id: data.id,
      slug: data.slug,

      name: data.name,
      start_at: Time.at(data.start_at),
      is_online: data.is_online,
      num_entrants: data.num_entrants,

      tournament_id: data.tournament.id,
      tournament_slug: data.tournament.slug,
      tournament_name: data.tournament.name
    }
    begin
      data.standings.nodes.each do |standing|
        if smashgg_id = standing&.entrant&.participants&.first&.user&.id
          placement = standing.placement
          if (placement || 0) > 0 && placement < 8
            idx = case placement
            when 5
              result.has_key?(:top5a_smashgg_user) ? '5b' : '5a'
            when 7
              result.has_key?(:top7a_smashgg_user) ? '7b' : '7a'
            else
              placement.to_s
            end
            slug = standing.entrant.participants.first.user.slug
            smashgg_user = SmashggUser.where(smashgg_id: smashgg_id)
                                      .first_or_create!(slug: slug)
            result["top#{idx}_smashgg_user".to_sym] = smashgg_user
          end
        end
      end
    rescue GraphQL::Client::UnfetchedFieldError
      puts 'standings not available'
    end
    result
  end

  def fetch_smashgg_data
    event_data = SmashggClient.new.get_event(
      event_id: smashgg_id,
      event_slug: slug,
      tournament_slug: tournament_slug
    )
    self.attributes = self.class.attributes_from_event_data(event_data)
  end

  def tournament_smashgg_url
    tournament_slug && "https://smash.gg/#{tournament_slug}/details"
  end

  def smashgg_url
    slug && "https://smash.gg/#{slug}"
  end

  def self.lookup(name:, from:, to:)
    data = SmashggClient.new.get_events(name: name, from: from, to: to)
    return nil if data.nil?
    data.map do |event_data|
      attributes = attributes_from_event_data(event_data)
      self.where(smashgg_id: attributes[:smashgg_id]).first_or_initialize(attributes)
    end
  end

  def smashgg_user_rank(smashgg_user_id)
    USER_NAMES.each do |user_name|
      return user_name if send("#{user_name}_id") == smashgg_user_id
    end
    nil
  end

  # ---------------------------------------------------------------------------
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i(name tournament_name)

end
