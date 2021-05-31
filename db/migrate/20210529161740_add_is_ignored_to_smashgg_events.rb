class AddIsIgnoredToSmashggEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :smashgg_events, :is_ignored, :boolean, null: false, default: false
  end
end
