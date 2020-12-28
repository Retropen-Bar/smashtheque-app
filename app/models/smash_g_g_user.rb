# == Schema Information
#
# Table name: smash_gg_users
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
#  slug                           :string
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
#  index_smash_gg_users_on_player_id   (player_id)
#  index_smash_gg_users_on_smashgg_id  (smashgg_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (player_id => players.id)
#
class SmashGGUser < ApplicationRecord

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

  after_create_commit :fetch_smashgg_data_later
  def fetch_smashgg_data_later
    FetchSmashGGUserDataJob.perform_later(self)
  end

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
    self.smashgg_player_id = data.user.player.id
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
