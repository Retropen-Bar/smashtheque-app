# == Schema Information
#
# Table name: smashgg_users
#
#  id                             :bigint           not null, primary key
#  avatar_url                     :string
#  banner_url                     :string
#  bio                            :text
#  birthday                       :string
#  city                           :string
#  country                        :string
#  discord_discriminated_username :string
#  events_last_imported_at        :datetime
#  gamer_tag                      :string
#  gender_pronoun                 :string
#  name                           :string
#  prefix                         :string
#  slug                           :string           not null
#  state                          :string
#  twitch_username                :string
#  twitter_username               :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  country_id                     :string
#  player_id                      :bigint
#  smashgg_id                     :integer          not null
#  smashgg_player_id              :string
#  state_id                       :string
#
# Indexes
#
#  index_smashgg_users_on_player_id   (player_id)
#  index_smashgg_users_on_slug        (slug) UNIQUE
#  index_smashgg_users_on_smashgg_id  (smashgg_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (player_id => players.id)
#
class SmashggUser < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :player, optional: true

  has_one :user, through: :player

  has_many  :owned_smashgg_events,
            class_name: :SmashggEvent,
            foreign_key: :tournament_owner_id,
            inverse_of: :tournament_owner,
            dependent: :nullify

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :slug, presence: true, uniqueness: true
  validates :smashgg_id, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_create_commit :fetch_smashgg_data_later
  def fetch_smashgg_data_later
    FetchSmashggUserDataJob.perform_later(self)
  end

  after_commit :update_player
  def update_player
    # only if record has new player and twitter_username
    return true unless previous_changes.key?('player_id') && player
    return true if twitter_username.blank?

    # only if user does not have a twitter_username yet
    return true if player.user&.twitter_username.present?

    player.return_or_create_user!.update(twitter_username: twitter_username)
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.with_player
    where.not(player_id: nil)
  end

  def self.without_player
    where(player_id: nil)
  end

  def self.unknown
    where(gamer_tag: nil)
  end

  def self.with_owned_events
    where(id: SmashggEvent.select(:tournament_owner_id))
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.slug_from_url(url)
    url.slice(/user\/[^\/]+/)
  end

  def smashgg_url=(url)
    self.slug = self.class.slug_from_url(url)
  end

  def smashgg_url
    slug && "https://www.start.gg/#{slug}"
  end

  def fetch_smashgg_data
    data = SmashggClient.new.get_user(
      user_id: smashgg_id,
      user_slug: slug
    )
    return if data.nil?

    self.smashgg_id = data.id
    self.slug = data.slug || data.id # sometimes slug doesn't exist
    self.name = data.name
    self.bio = data.bio
    self.birthday = data.birthday
    self.gender_pronoun = data.gender_pronoun
    self.city = data.location&.city
    self.country = data.location&.country
    self.country_id = data.location&.country_id
    self.state = data.location&.state
    self.state_id = data.location&.state_id
    self.smashgg_player_id = data.player&.id
    self.gamer_tag = data.player&.gamer_tag
    self.prefix = data.player&.prefix
    data.images&.each do |image|
      case image.type.to_sym
      when :banner
        self.banner_url = image.url
      when :profile
        self.avatar_url = image.url
      end
    end
    data.authorizations&.each do |authorization|
      case authorization.type.downcase.to_sym
      when :twitch
        self.twitch_username = authorization.external_username
      when :twitter
        self.twitter_username = authorization.external_username
      when :discord
        self.discord_discriminated_username = authorization.external_username
      end
    end
    data
  end

  def self.from_data(smashgg_id:, slug:)
    # sometimes slug doesn't exist, so we cheat a bit here
    where(smashgg_id: smashgg_id).first_or_create!(slug: slug || smashgg_id)
  end

  def self.fetch_unknown
    unknown.find_each do |smashgg_user|
      smashgg_user.fetch_smashgg_data
      smashgg_user.save
    end
  end

  def smashgg_events
    SmashggEvent.with_smashgg_user(id)
  end

  def fetch_smashgg_events
    data = SmashggClient.new.get_user_events(user_id: smashgg_id)
    return [] if data.nil?

    data.filter_map do |event_data|
      attributes = SmashggEvent.attributes_from_event_data(event_data)
      attributes && SmashggEvent.where(smashgg_id: attributes[:smashgg_id]).first_or_initialize(attributes)
    end
  end

  def import_missing_smashgg_events
    fetch_smashgg_events.each do |smashgg_event|
      next if smashgg_event.already_imported?

      sleep 1 # sleep to avoid hitting API rate limits
      unless smashgg_event.import
        # do not exit on errors, but log them
        Rails.logger.debug "SmashggEvent errors: #{smashgg_event.errors.full_messages}"
      end
    end
    # remember we did this
    touch :events_last_imported_at
  end

  # import missing events for users linked to a player
  def self.import_missing_smashgg_events_which_matter
    users = with_player.order(id: :desc)
    logger.debug '*' * 50
    logger.debug 'IMPORT MISSING SGG EVENTS WHICH MATTER'
    logger.debug '*' * 50
    users.each_with_index do |user, idx|
      logger.debug "Handle sgg user #{idx}/#{users.size}: ##{user.id}"
      user.import_missing_smashgg_events
    end
  end
end
