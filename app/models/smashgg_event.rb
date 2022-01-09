# == Schema Information
#
# Table name: smashgg_events
#
#  id                    :bigint           not null, primary key
#  is_ignored            :boolean          default(FALSE), not null
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
  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include IsBracket

  # ---------------------------------------------------------------------------
  # CONSTANTS
  # ---------------------------------------------------------------------------

  USER_NAMES = TournamentEvent::TOP_RANKS.map do |rank|
    "top#{rank}_smashgg_user".to_sym
  end.freeze
  USER_NAME_RANK = TournamentEvent::TOP_RANKS.map do |rank|
    [
      "top#{rank}_smashgg_user".to_sym,
      case rank
      when '5a', '5b' then 5
      when '7a', '7b' then 7
      else rank.to_i
      end
    ]
  end.to_h.freeze
  SHORT_URL_REGEXP = %r{\Ahttps://smash.gg/[^/]+\z}
  EVENT_URL_REGEXP = %r{tournament/[^/]+/event/[^/]+}
  TOURNAMENT_URL_REGEXP = %r{tournament/[^/]+}

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

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :smashgg_id, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.with_smashgg_user(smashgg_user_id)
    where(
      USER_NAMES.map do |user_name|
        "#{user_name}_id = ?"
      end.join(' OR '),
      *USER_NAMES.map { smashgg_user_id }
    )
  end

  def self.with_available_player_ranked(rank)
    user_name = "top#{rank}_smashgg_user".to_sym
    player_id = "top#{rank}_player_id".to_sym

    where(
      id: self.joins(user_name)
              .joins(:tournament_event)
              .where.not(smashgg_users: { player_id: nil })
              .where(tournament_events: { player_id => nil })
              .select(:id)
    )
  end

  def self.with_available_players
    with_available_player_ranked(1).or(
      with_available_player_ranked(2)
    ).or(
      with_available_player_ranked(3)
    ).or(
      with_available_player_ranked(4)
    ).or(
      with_available_player_ranked('5a')
    ).or(
      with_available_player_ranked('5b')
    ).or(
      with_available_player_ranked('7a')
    ).or(
      with_available_player_ranked('7b')
    )
  end

  def self.with_wrong_players_ranked(rank)
    user_name = "top#{rank}_smashgg_user".to_sym
    player_id = "top#{rank}_player_id".to_sym

    where(
      id: self.joins(user_name)
              .joins(:tournament_event)
              .where.not(smashgg_users: { player_id: nil })
              .where.not(tournament_events: { player_id => nil })
              .where("tournament_events.#{sanitize_sql(player_id)} != smashgg_users.player_id")
              .select(:id)
    )
  end

  def self.wrong_players_ranked(rank)
    user_name = "top#{rank}_smashgg_user".to_sym
    player_id = "top#{rank}_player_id".to_sym

    self.joins(user_name)
        .joins(:tournament_event)
        .where.not(smashgg_users: { player_id: nil })
        .where.not(tournament_events: { player_id => nil })
        .where("tournament_events.#{sanitize_sql(player_id)} != smashgg_users.player_id")
        .pluck(
          :id,
          'smashgg_users.id',
          'smashgg_users.player_id',
          'tournament_events.id',
          "tournament_events.#{sanitize_sql(player_id)}"
        ).map do |data|
          {
            rank: rank,
            smashgg_event_id: data[0],
            smashgg_user_id: data[1],
            smashgg_user_player_id: data[2],
            tournament_event_id: data[3],
            tournament_event_player_id: data[4]
          }
        end
  end

  def self.with_wrong_players
    with_wrong_players_ranked(1).or(
      with_wrong_players_ranked(2)
    ).or(
      with_wrong_players_ranked(3)
    ).or(
      with_wrong_players_ranked(4)
    ).or(
      with_wrong_players_ranked('5a')
    ).or(
      with_wrong_players_ranked('5b')
    ).or(
      with_wrong_players_ranked('7a')
    ).or(
      with_wrong_players_ranked('7b')
    )
  end

  def self.wrong_players
    wrong_players_ranked(1) +
    wrong_players_ranked(2) +
    wrong_players_ranked(3) +
    wrong_players_ranked(4) +
    wrong_players_ranked('5a') +
    wrong_players_ranked('5b') +
    wrong_players_ranked('7a') +
    wrong_players_ranked('7b')
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.long_url_from_short_url(url)
    Net::HTTP.get_response(URI.parse(url))['location']
  rescue StandardError => e
    logger.debug "Error fetching short URL: #{e.inspect}"
    ''
  end

  def self.slug_from_url(url)
    url = long_url_from_short_url(url) if SHORT_URL_REGEXP =~ url
    url.slice(EVENT_URL_REGEXP)
  end

  def self.tournament_slug_from_url(url)
    url = long_url_from_short_url(url) if SHORT_URL_REGEXP =~ url
    url.slice(TOURNAMENT_URL_REGEXP)
  end

  def smashgg_url=(url)
    url = self.class.long_url_from_short_url(url) if SHORT_URL_REGEXP =~ url
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
    slug = slug_from_url(url)
    return from_slug(slug) if slug

    tournament_slug = tournament_slug_from_url(url)
    return from_tournament_slug(tournament_slug) if tournament_slug

    nil
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
    # sometimes data.standings is nil
    if data.standings.nil?
      Rails.logger.debug 'standings not available (Hash)'
      Rollbar.log('debug', 'Standings not available (Hash)', slug: data.slug)
      return result
    end
    begin
      data.standings.nodes.each do |standing|
        smashgg_id = standing&.entrant&.participants&.first&.user&.id
        next unless smashgg_id

        placement = standing.placement
        next unless (placement || 0).positive? && placement < 8

        idx =
          case placement
          when 5, 6
            result.key?(:top5a_smashgg_user) ? '5b' : '5a'
          when 7, 8
            result.key?(:top7a_smashgg_user) ? '7b' : '7a'
          else
            placement.to_s
          end
        slug = standing.entrant.participants.first&.user&.slug
        next if slug.blank?

        smashgg_user = SmashggUser.where(smashgg_id: smashgg_id).first_or_create!(slug: slug)
        result["top#{idx}_smashgg_user".to_sym] = smashgg_user
      end
    rescue GraphQL::Client::UnfetchedFieldError
      Rails.logger.debug 'standings not available (GraphQL)'
      Rollbar.log('debug', 'Standings not available (GraphQL)', slug: data.slug)
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

  alias_method :fetch_provider_data, :fetch_smashgg_data

  def tournament_smashgg_url
    tournament_slug && "https://smash.gg/#{tournament_slug}/details"
  end

  def smashgg_url
    slug && "https://smash.gg/#{slug}"
  end

  def self.lookup(name:, from:, to:, country:)
    data = SmashggClient.new.get_events(
      name: name,
      from: from,
      to: to,
      country: country
    )
    return nil if data.nil?

    data.map do |event_data|
      attributes = attributes_from_event_data(event_data)
      where(smashgg_id: attributes[:smashgg_id]).first_or_initialize(attributes)
    end
  end

  def self.import_all(name:, from:, to:, country:)
    lookup(name: name, from: from, to: to, country: country).each do |smashgg_event|
      sleep 1
      smashgg_event.fetch_smashgg_data
      smashgg_event.save
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
  multisearchable against: %i[name tournament_name]
end
