class AddEventsLastImportedAtToSmashggUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :smashgg_users, :events_last_imported_at, :datetime
  end
end
