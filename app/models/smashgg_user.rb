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

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :smashgg_id, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.with_player
    where.not(player_id: nil)
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
    slug && "https://smash.gg/#{slug}"
  end

  def fetch_smashgg_data
    data = SmashggClient.new.get_user(
      user_id: smashgg_id,
      user_slug: slug
    )

    self.smashgg_id = data.id
    self.slug = data.slug
    self.name = data.name
    self.bio = data.bio
    self.birthday = data.birthday
    self.gender_pronoun = data.gender_pronoun
    self.city = data.location.city
    self.country = data.location.country
    self.country_id = data.location.country_id
    self.state = data.location.state
    self.state_id = data.location.state_id
    self.smashgg_player_id = data.player.id
    self.gamer_tag = data.player.gamer_tag
    self.prefix = data.player.prefix
    data.images.each do |image|
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
      smashgg_user.save!
    end
  end

end
