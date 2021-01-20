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
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :locations_players, dependent: :destroy
  has_many :players, through: :locations_players
  has_many :discord_guild_relateds, as: :related, dependent: :destroy
  has_many :discord_guilds, through: :discord_guild_relateds

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
