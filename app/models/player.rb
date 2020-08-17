class Player < ApplicationRecord

  belongs_to :city, optional: true
  belongs_to :team, optional: true

  has_many :characters_players, dependent: :destroy
  has_many :characters, through: :characters_players

  validates :name, presence: true

end
