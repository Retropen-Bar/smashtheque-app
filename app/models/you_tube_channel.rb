# == Schema Information
#
# Table name: you_tube_channels
#
#  id           :bigint           not null, primary key
#  description  :text
#  is_french    :boolean          default(FALSE), not null
#  related_type :string
#  username     :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  related_id   :bigint
#
# Indexes
#
#  index_you_tube_channels_on_related_type_and_related_id  (related_type,related_id)
#  index_you_tube_channels_on_username                     (username) UNIQUE
#
class YouTubeChannel < ApplicationRecord

  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include RelatedConcern
  def self.related_types
    [
      Character,
      Location,
      Player,
      Team
    ]
  end

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :username, uniqueness: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    RetropenBotScheduler.rebuild_youtube
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.french
    where(is_french: true)
  end

  def self.not_french
    where(is_french: false)
  end

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
