class ApiRequest < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :api_token, optional: true

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :remote_ip, presence: true
  validates :controller, presence: true
  validates :action, presence: true
  validates :requested_at, presence: true

end
