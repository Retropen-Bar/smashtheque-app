class Team < ApplicationRecord

  has_many :players

  validates :short_name, presence: true
  validates :name, presence: true

end
