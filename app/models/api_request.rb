# == Schema Information
#
# Table name: api_requests
#
#  id           :bigint           not null, primary key
#  action       :string
#  controller   :string
#  remote_ip    :inet
#  requested_at :datetime
#  api_token_id :bigint
#
# Indexes
#
#  index_api_requests_on_api_token_id  (api_token_id)
#
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
