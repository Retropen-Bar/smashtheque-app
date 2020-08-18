class Player < ApplicationRecord

  belongs_to :city, optional: true
  belongs_to :team, optional: true

  has_many :characters_players, dependent: :destroy
  has_many :characters, through: :characters_players

  validates :name, presence: true

  def self.on_abc(letter)
    where("name ILIKE '#{letter}%'")
  end

  def self.on_abc_others
    result = self
    ('a'..'z').each do |letter|
      result = result.where.not("name ILIKE '#{letter}%'")
    end
    result
  end

end
