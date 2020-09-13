# == Schema Information
#
# Table name: locations_players
#
#  id          :bigint           not null, primary key
#  position    :integer
#  location_id :bigint           not null
#  player_id   :bigint           not null
#
# Indexes
#
#  index_locations_players_on_location_id                (location_id)
#  index_locations_players_on_location_id_and_player_id  (location_id,player_id) UNIQUE
#  index_locations_players_on_player_id                  (player_id)
#
class LocationsPlayer < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :location
  belongs_to :player

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :location_id, uniqueness: { scope: :player_id }

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # this is required because when a Player is destroyed,
  # old relations are not available inside an after_commit callback
  # so we can't know inside Player#update_discord which locations it had
  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    if player.is_legit? && player&.destroyed?
      # this is the deletion of a player
      RetropenBotScheduler.rebuild_locations_for_location location
    end
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.positioned
    order(:position)
  end

end
