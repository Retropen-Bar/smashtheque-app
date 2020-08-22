class AddIsAcceptedToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :is_accepted, :boolean
    Player.update_all is_accepted: true
  end
end
