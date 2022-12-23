class AddLastImportedAtToSmashggEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :smashgg_events, :last_imported_at, :datetime
  end
end
