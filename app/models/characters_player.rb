class CharactersPlayer < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :character
  belongs_to :player

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # this is required because when a Player is destroyed,
  # old relations are not available inside an after_commit callback
  # so we can't know inside Player#update_discord which characters it had
  after_commit :update_discord
  def update_discord
    if player.destroyed?
      # this is the deletion of a player
      RetropenBot.default.rebuild_chars_for_character character
    end
  end

end
