class SmashGGUser < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :discord_user, optional: true
  has_one :player

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :smashgg_id, presence: true, uniqueness: true
  validates :discord_user, uniqueness: { allow_nil: true }

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.with_player
    where(id: Player.select(:smash_gg_user_id))
  end

  def self.unknown
    where(gamer_tag: nil)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def fetch_smashgg_data
    raise 'Unknown smashgg_id' if smashgg_id.blank?

    data = SmashGGClient.new.get_user_data(smashgg_id)

    self.slug = data.user.slug
    self.name = data.user.name
    self.bio = data.user.bio
    self.birthday = data.user.birthday
    self.gender_pronoun = data.user.gender_pronoun
    self.city = data.user.location.city
    self.country = data.user.location.country
    self.country_id = data.user.location.country_id
    self.state = data.user.location.state
    self.state_id = data.user.location.state_id
    self.player_id = data.user.player.id
    self.gamer_tag = data.user.player.gamer_tag
    self.prefix = data.user.player.prefix
    data.user.images.each do |image|
      case image.type.to_sym
      when :banner
        self.banner_url = image.url
      when :profile
        self.avatar_url = image.url
      end
    end
    data.user.authorizations.each do |authorization|
      case authorization.type.downcase.to_sym
      when :twitch
        self.twitch_username = authorization.external_username
      when :twitter
        self.twitter_username = authorization.external_username
      when :discord
        self.discord_discriminated_username = authorization.external_username
        self.discord_user = DiscordUser.by_discriminated_username(authorization.external_username).first
      end
    end
  end

  def self.fetch_unknown
    unknown.find_each do |smash_gg_user|
      smash_gg_user.fetch_smashgg_data
      smash_gg_user.save!
    end
  end

end
