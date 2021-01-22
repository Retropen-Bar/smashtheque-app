# == Schema Information
#
# Table name: duos
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  player1_id :bigint           not null
#  player2_id :bigint           not null
#
# Indexes
#
#  index_duos_on_name        (name)
#  index_duos_on_player1_id  (player1_id)
#  index_duos_on_player2_id  (player2_id)
#
# Foreign Keys
#
#  fk_rails_...  (player1_id => players.id)
#  fk_rails_...  (player2_id => players.id)
#
class Duo < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :player1, class_name: :Player
  belongs_to :player2, class_name: :Player

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :name, presence: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.by_name_like(name)
    where('name ILIKE ?', name)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def as_json(options = {})
    super(options.merge(
      include: {
        player1: {
          only: %i(id name)
        },
        player2: {
          only: %i(id name)
        }
      }
    ))
  end

  # ---------------------------------------------------------------------------
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i(name)

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
