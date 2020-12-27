class AddRankToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :rank, :integer
  end
end
