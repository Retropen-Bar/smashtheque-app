# == Schema Information
#
# Table name: twitch_channels
#
#  id           :bigint           not null, primary key
#  description  :text
#  is_french    :boolean
#  related_type :string
#  username     :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  related_id   :bigint
#
# Indexes
#
#  index_twitch_channels_on_related_type_and_related_id  (related_type,related_id)
#  index_twitch_channels_on_username                     (username) UNIQUE
#
class TwitchChannel < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :related, polymorphic: true, optional: true

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :username, uniqueness: true

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.by_related_type(v)
    where(related_type: v)
  end

  def self.by_related_id(v)
    where(related_id: v)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def related_gid
    self.related&.to_global_id&.to_s
  end

  def related_gid=(gid)
    self.related = GlobalID::Locator.locate gid
  end

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
