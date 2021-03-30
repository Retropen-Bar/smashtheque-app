# == Schema Information
#
# Table name: communities
#
#  id         :bigint           not null, primary key
#  address    :string           not null
#  latitude   :float            not null
#  longitude  :float            not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Community < ApplicationRecord

  # ---------------------------------------------------------------------------
  # MODULES
  # ---------------------------------------------------------------------------

  geocoded_by :address

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :discord_guild_relateds, as: :related, dependent: :destroy
  has_many :discord_guilds, through: :discord_guild_relateds

  has_many :you_tube_channels, as: :related, dependent: :nullify

  has_many :twitch_channels, as: :related, dependent: :nullify

  has_one_attached :logo

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

  def self.on_abc(letter)
    where("unaccent(name) ILIKE '#{letter}%'")
  end

  def self.by_name_like(name)
    where('unaccent(name) ILIKE unaccent(?)', name)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def first_discord_guild
    discord_guilds.first
  end

  def users(radius: 50)
    User.near_community(self, radius: radius)
  end

  def players(radius: 50)
    Player.near_community(self, radius: radius)
  end

  def logo_url
    return nil unless logo.attached?
    logo.service_url
  end

  def logo_url=(url)
    return false if url.blank?
    uri = URI.parse(url)
    open(url) do |f|
      logo.attach(io: File.open(f.path), filename: File.basename(uri.path))
    end
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
