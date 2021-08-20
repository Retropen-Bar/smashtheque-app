class AddValidatedCharterAt < ActiveRecord::Migration[6.0]
  def change
    add_column :recurring_tournaments, :signed_charter_at, :date
    add_index :recurring_tournaments, :signed_charter_at
    add_belongs_to  :recurring_tournaments,
                    :charter_signer_user,
                    foreign_key: { to_table: :users },
                    index: true
  end
end
