class AddDateDescriptionToRecurringTournaments < ActiveRecord::Migration[6.0]
  def change
    add_column :recurring_tournaments, :date_description, :string
  end
end
