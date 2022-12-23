# == Schema Information
#
# Table name: smashgg_events
#
#  id                    :bigint           not null, primary key
#  is_ignored            :boolean          default(FALSE), not null
#  is_online             :boolean
#  latitude              :float
#  longitude             :float
#  name                  :string
#  num_entrants          :integer
#  primary_contact       :string
#  primary_contact_type  :string
#  slug                  :string           not null
#  start_at              :datetime
#  tournament_name       :string
#  tournament_slug       :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  discord_guild_id      :bigint
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
#  tournament_owner_id   :bigint
#
# Indexes
#
#  index_smashgg_events_on_discord_guild_id       (discord_guild_id)
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
#  index_smashgg_events_on_tournament_owner_id    (tournament_owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (discord_guild_id => discord_guilds.id)
#  fk_rails_...  (top1_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top2_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top3_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top4_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top5a_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top5b_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top7a_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (top7b_smashgg_user_id => smashgg_users.id)
#  fk_rails_...  (tournament_owner_id => smashgg_users.id)
#
class SmashggEvent < ApplicationRecord
  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include IsBracket

  # ---------------------------------------------------------------------------
  # MODULES
  # ---------------------------------------------------------------------------

  geocoded_by :address

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
  SHORT_URL_REGEXP = %r{\Ahttps://(smash|start).gg/[^/]+\z}
  EVENT_URL_REGEXP = %r{tournament/[^/]+/event/[^/]+}
  TOURNAMENT_URL_REGEXP = %r{tournament/[^/]+}
  ICON_URL = 'https://developer.start.gg/img/favicon/favicon.ico'.freeze

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :discord_guild, optional: true
  belongs_to :tournament_owner, class_name: :SmashggUser, optional: true
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
            rank: rank.to_i,
            smashgg_event_id: data[0],
            smashgg_user_id: data[1],
            smashgg_user_player_id: data[2],
            tournament_event_id: data[3],
            tournament_event_player_id: data[4]
          }
        end
  end

  def self.false_wrong_players?(wrong_player1, wrong_player2)
    return false unless wrong_player1[:smashgg_event_id] == wrong_player2[:smashgg_event_id]
    return false unless wrong_player1[:rank] == wrong_player2[:rank]
    return false unless [5, 7].include?(wrong_player1[:rank])

    (
      wrong_player1[:smashgg_user_player_id] == wrong_player2[:tournament_event_player_id]
    ) && (
      wrong_player1[:tournament_event_player_id] == wrong_player2[:smashgg_user_player_id]
    )
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

  def top_smashgg_user_ids
    USER_NAMES.filter_map do |user_name|
      send("#{user_name}_id")
    end
  end

  def self.long_url_from_short_url(url)
    Net::HTTP.get_response(URI.parse(url))['location']
  rescue StandardError => e
    logger.debug "Error fetching short URL: #{e.inspect}"
    ''
  end

  def self.is_short_url?(url)
    SHORT_URL_REGEXP =~ url
  end

  def self.slug_from_url(url)
    return nil if url.blank?

    url = long_url_from_short_url(url) if is_short_url?(url)
    url.slice(EVENT_URL_REGEXP)
  end

  def self.tournament_slug_from_url(url)
    url = long_url_from_short_url(url) if is_short_url?(url)
    url.slice(TOURNAMENT_URL_REGEXP)
  end

  def smashgg_url=(url)
    url = self.class.long_url_from_short_url(url) if self.class.is_short_url?(url)
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
    return {} if data.nil?

    result = {
      smashgg_id: data.id,
      slug: data.slug,

      name: data.name,
      start_at: Time.at(data.start_at),
      is_online: data.is_online,
      num_entrants: data.num_entrants,

      tournament_id: data.tournament.id,
      tournament_slug: data.tournament.slug,
      tournament_name: data.tournament.name,

      latitude: data.tournament.lat,
      longitude: data.tournament.lng,
      primary_contact_type: data.tournament.primary_contact_type,
      primary_contact: data.tournament.primary_contact
    }

    # owner
    result[:tournament_owner] = SmashggUser.from_data(
      smashgg_id: data.tournament.owner.id,
      slug: data.tournament.owner.slug
    )

    # Discord guild
    if data.tournament.primary_contact_type == 'discord'
      result[:discord_guild] = DiscordGuild.from_data(
        invitation_url: data.tournament.primary_contact
      )
    end

    begin
      # sometimes data.standings is nil
      if data.standings.nil?
        Rails.logger.debug 'standings not available (Hash)'
        # Rollbar.log('debug', 'Standings not available (Hash)', slug: data.slug)
        return result
      end

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

        result["top#{idx}_smashgg_user".to_sym] = SmashggUser.from_data(
          smashgg_id: smashgg_id,
          slug: slug
        )
      end
    rescue GraphQL::Client::UnfetchedFieldError
      Rails.logger.debug 'standings not available (GraphQL)'
      # Rollbar.log('debug', 'Standings not available (GraphQL)', slug: data.slug)
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
    tournament_slug && "https://www.start.gg/#{tournament_slug}/details"
  end

  def smashgg_url
    slug && "https://www.start.gg/#{slug}"
  end

  def self.lookup(name:, from:, to:, country:)
    data = SmashggClient.new.get_events(
      name: name,
      from: from,
      to: to,
      country: country
    )
    return nil if data.nil?

    data.filter_map do |event_data|
      attributes = attributes_from_event_data(event_data)
      attributes && where(smashgg_id: attributes[:smashgg_id]).first_or_initialize(attributes)
    end
  end

  def self.import_all(name:, from:, to:, country:)
    lookup(name: name, from: from, to: to, country: country).each do |smashgg_event|
      next if smashgg_event.already_imported?

      sleep 1 # sleep to avoid hitting API rate limits
      unless smashgg_event.import
        # do not exit on errors, but log them
        Rails.logger.debug "SmashggEvent errors: #{smashgg_event.errors.full_messages}"
      end
    end
  end

  # returns the existing or created TournamentEvent, or a falsey value
  def import
    # fetch data because even if some attributes are already here, standings are not fetched yet
    fetch_smashgg_data
    save && create_tournament_event_if_missing
  end

  # TODO: handle 2v2 properly
  def create_tournament_event_if_missing
    return any_tournament_event if already_imported?
    return nil if top_smashgg_user_ids.count < 4 # we could adjust this threshold

    # if we are here, it means no TournamentEvent exists yet for this event
    # and it was not a waiting list since there are players in final standing
    tournament_event = TournamentEvent.new(bracket: self)
    tournament_event.use_bracket(true)
    tournament_event.save && tournament_event
  end

  def already_imported?
    persisted? && (is_ignored? || any_tournament_event)
  end

  def smashgg_user_rank(smashgg_user_id)
    USER_NAMES.each do |user_name|
      return user_name if send("#{user_name}_id") == smashgg_user_id
    end
    nil
  end

  def is_offline?
    !is_online?
  end

  # ---------------------------------------------------------------------------
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i[name tournament_name]
end
