# == Schema Information
#
# Table name: locations
#
#  id         :bigint           not null, primary key
#  icon       :string
#  is_main    :boolean
#  latitude   :float
#  longitude  :float
#  name       :string
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_locations_on_type  (type)
#
class Location < ApplicationRecord

  # ---------------------------------------------------------------------------
  # MODULES
  # ---------------------------------------------------------------------------

  geocoded_by :name

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :discord_guild_relateds, as: :related, dependent: :destroy
  has_many :discord_guilds, through: :discord_guild_relateds

  has_many :you_tube_channels, as: :related, dependent: :nullify

  has_many :twitch_channels, as: :related, dependent: :nullify

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  # validates :icon, presence: true
  validates :name, presence: true#, uniqueness: true
  validate :name_should_be_unique

  def name_should_be_unique
    if Location.default_scoped.where.not(id: id).by_name_like(name).any?
      errors.add(:name, :unique)
    end
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.on_abc(letter)
    where("unaccent(name) ILIKE '#{letter}%'")
  end

  def self.by_name_like(name)
    where('unaccent(name) ILIKE unaccent(?)', name)
  end

  def self.geocoded
    where.not(latitude: nil)
  end

  def self.not_geocoded
    where(latitude: nil)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def is_geocoded?
    !latitude.nil?
  end

  def users
    User.near([latitude, longitude], 50, units: :km)
  end

  def players
    users.map(&:player).compact
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
