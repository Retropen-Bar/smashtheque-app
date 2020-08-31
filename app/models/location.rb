class Location < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :players

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  # validates :icon, presence: true
  validates :name, presence: true#, uniqueness: true
  validate :name_should_be_unique

  def name_should_be_unique
    if Location.where.not(id: id).by_name_like(name).any?
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
