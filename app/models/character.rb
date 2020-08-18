class Character < ApplicationRecord

  has_many :characters_players, dependent: :destroy
  has_many :players, through: :characters_players

  validates :name, presence: true, uniqueness: true
  validates :icon, presence: true
  validates :emoji, presence: true, uniqueness: true
  validates :head_icon_url, presence: true, uniqueness: true

end
