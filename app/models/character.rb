# == Schema Information
#
# Table name: characters
#
#  id                    :bigint           not null, primary key
#  background_color      :string
#  background_image      :text
#  background_size       :integer
#  emoji                 :string
#  icon                  :string
#  name                  :string
#  nintendo_url          :string
#  official_number       :string           default(""), not null
#  origin                :string
#  other_names           :string           default([]), is an Array
#  smashprotips_url      :string
#  ultimateframedata_url :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_characters_on_official_number  (official_number) UNIQUE
#
class Character < ApplicationRecord
  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include HasName
  def self.on_abc_name
    :name
  end

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :characters_players, dependent: :destroy
  has_many :players, through: :characters_players

  has_many :discord_guild_relateds, as: :related, dependent: :destroy
  has_many :discord_guilds, through: :discord_guild_relateds

  has_many :you_tube_channels, as: :related, dependent: :nullify

  has_many :twitch_channels, as: :related, dependent: :nullify

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :name, presence: true, uniqueness: true
  validates :icon, presence: true
  validates :emoji, presence: true, uniqueness: true
  validates :official_number, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  def other_names=(values)
    super values.reject(&:blank?)
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :ordered_by_official_number, -> { order(:official_number) }

  def self.by_emoji(emoji)
    where(emoji: emoji)
  end

  def self.without_background
    where(background_color: [nil, ''])
  end

  def self.with_discord_guild
    where(id: DiscordGuildRelated.by_related_type(Character.to_s).select(:related_id))
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.first_character
    ordered_by_official_number.first
  end

  def previous_character
    self.class.where('official_number < ?', official_number).ordered_by_official_number.last
  end

  def next_character
    self.class.where('official_number > ?', official_number).ordered_by_official_number.first
  end

  def self.last_character
    ordered_by_official_number.last
  end

  # ---------------------------------------------------------------------------
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i[name other_names]

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
