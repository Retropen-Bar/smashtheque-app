class ApiToken < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :api_requests

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :name, presence: true, uniqueness: true
  validates :token, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # INITIALIZERS
  # ---------------------------------------------------------------------------

  def initialize(params = {})
    super
    self.token = SecureRandom.hex
  end

end
