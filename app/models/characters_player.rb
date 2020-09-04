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
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # this is required because when a Player is destroyed,
  # old relations are not available inside an after_commit callback
  # so we can't know inside Player#update_discord which characters it had
  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    if player.is_accepted? && player&.destroyed?
      # this is the deletion of a player
      RetropenBotScheduler.rebuild_chars_for_character character
    end
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.positioned
    order(:position)
  end

end
