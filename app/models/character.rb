class Character < ApplicationRecord

  has_many :characters_players, dependent: :destroy
  has_many :players, through: :characters_players

  validates :name, presence: true
  validates :icon, presence: true

end
