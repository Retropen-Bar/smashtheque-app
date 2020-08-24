class AddCreatorToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :players, :creator, index: true
    Player.update_all creator_id: DiscordUser.first.id
  end
end
