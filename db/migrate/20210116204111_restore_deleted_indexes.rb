class RestoreDeletedIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :recurring_tournament_contacts,
              %w(recurring_tournament_id user_id),
              name: :index_rtc_on_both_ids,
              unique: true
    add_index :team_admins,
              %w(team_id user_id),
              unique: true
  end
end
