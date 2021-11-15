# == Schema Information
#
# Table name: communities
#
#  id               :bigint           not null, primary key
#  address          :string           not null
#  latitude         :float            not null
#  longitude        :float            not null
#  name             :string           not null
#  ranking_url      :string
#  twitter_username :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Community < ApplicationRecord
  # ---------------------------------------------------------------------------
  # MODULES
  # ---------------------------------------------------------------------------

  geocoded_by :address

  include HasTwitter

  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include HasLogo

  include HasName
  def self.on_abc_name
    :name
  end

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :discord_guild_relateds, as: :related, dependent: :destroy
  has_many :discord_guilds, through: :discord_guild_relateds

  has_many :you_tube_channels, as: :related, dependent: :nullify

  has_many :twitch_channels, as: :related, dependent: :nullify

  has_many :community_admins,
           inverse_of: :community,
           dependent: :destroy
  has_many :admins,
           through: :community_admins,
           source: :user

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :name, presence: true
  validates :address, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.by_name_like(name)
    where('unaccent(name) ILIKE unaccent(?)', name)
  end

  def self.administrated_by(user_id)
    where(id: CommunityAdmin.where(user_id: user_id).select(:community_id))
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def first_discord_guild
    discord_guilds.first
  end

  def admin_discord_ids
    admins.map(&:discord_id)
  end

  def users(radius: 50)
    User.near_community(self, radius: radius)
  end

  def players(radius: 50)
    Player.near_community(self, radius: radius)
  end

  # ---------------------------------------------------------------------------
  # GLOBAL SEARCH
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i(name)

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }
end
