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

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :slug, presence: true, uniqueness: true
  validates :smashgg_id, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

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
    self.slug = data.slug
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
    return nil if data.nil?

    data.map do |event_data|
      attributes = SmashggEvent.attributes_from_event_data(event_data)
      SmashggEvent.where(smashgg_id: attributes[:smashgg_id]).first_or_initialize(attributes)
    end
  end

  def import_missing_smashgg_events
    fetch_smashgg_events.each do |smashgg_event|
      next if smashgg_event.persisted?

      smashgg_event.fetch_smashgg_data # because standings are not fetched yet
      unless smashgg_event.save
        # do not exit on errors
        Rails.logger.debug "SmashggEvent errors: #{smashgg_event.errors.full_messages}"
      end
    end
  end

  # returns [player, reason]
  def suggested_player
    if discord_discriminated_username
      discord_user = DiscordUser.by_discriminated_username(
        discord_discriminated_username
      ).first
      if discord_user && discord_user.player
        return [discord_user.player, :discord_discriminated_username]
      end
    end
    if twitter_username
      user = User.where(twitter_username: twitter_username).first
      player = user&.player
      return [player, :twitter_username] if player
    end
    if gamer_tag
      if Player.by_name_like(gamer_tag).count == 1
        return [Player.by_name_like(gamer_tag).first, :gamer_tag]
      end
    end
    smashgg_events.each do |smashgg_event|
      if tournament_event = smashgg_event.tournament_event
        smashgg_event_rank = SmashggEvent::USER_NAME_RANK[
          smashgg_event.smashgg_user_rank(id)
        ]
        player_names =
          case smashgg_event_rank
          when 5
            %i(top5a_player top5b_player)
          when 7
            %i(top7a_player top7b_player)
          else
            ["top#{smashgg_event_rank}_player".to_sym]
          end
        player_names.each do |player_name|
          player = tournament_event.send(player_name)
          if player && player.smashgg_users.none?
            return [player, :smashgg_event, smashgg_event]
          end
        end
      end
    end
    nil
  end

end
