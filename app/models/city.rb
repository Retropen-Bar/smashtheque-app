class City < ApplicationRecord

  has_many :players

  validates :icon, presence: true
  validates :name, presence: true, uniqueness: true

end
