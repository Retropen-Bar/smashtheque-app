class RemoveHasGoodNetworkFromPlayers < ActiveRecord::Migration[6.0]
  def change
    remove_column :players, :has_good_network
  end
end
