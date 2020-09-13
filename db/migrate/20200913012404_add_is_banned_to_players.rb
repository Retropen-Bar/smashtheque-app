class AddIsBannedToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :is_banned, :boolean, null: false, default: false
    add_column :players, :ban_details, :text
  end
end
