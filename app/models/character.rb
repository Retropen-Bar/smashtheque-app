class Character < ApplicationRecord

  has_many :characters_players, dependent: :destroy
  has_many :players, through: :characters_players

  validates :name, presence: true, uniqueness: true
  validates :icon, presence: true
  validates :emoji, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.on_abc(letter)
    where("unaccent(name) ILIKE '#{letter}%'")
  end

  # ---------------------------------------------------------------------------
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch
  multisearchable against: %i(name)

end
