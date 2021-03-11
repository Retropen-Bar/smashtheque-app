class AddHasGoodNetworkToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :has_good_network, :boolean, null: false, default: false
  end
end
