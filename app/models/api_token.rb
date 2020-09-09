# == Schema Information
#
# Table name: api_tokens
#
#  id         :bigint           not null, primary key
#  name       :string
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_api_tokens_on_token  (token) UNIQUE
#
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
