# == Schema Information
#
# Table name: characters_players
#
#  id           :bigint           not null, primary key
#  position     :integer
#  character_id :bigint           not null
#  player_id    :bigint           not null
#
# Indexes
#
#  index_characters_players_on_character_id                (character_id)
#  index_characters_players_on_character_id_and_player_id  (character_id,player_id) UNIQUE
#  index_characters_players_on_player_id                   (player_id)
#
# Foreign Keys
#
#  fk_rails_...  (character_id => characters.id)
#  fk_rails_...  (player_id => players.id)
#
class CharactersPlayer < ApplicationRecord
  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :character
  belongs_to :player

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :character_id, uniqueness: { scope: :player_id }


  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :positioned, -> { order(:position) }
  scope :mains, -> { where(position: 0) }
  scope :secondaries, -> { where.not(position: 0) }
end
