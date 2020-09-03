class MultiplyPlayerRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations_players do |t|
      t.belongs_to :player
      t.belongs_to :location
      t.integer :position
    end
    add_column :players, :location_names, :text, default: [], array: true

    create_table :players_teams do |t|
      t.belongs_to :player
      t.belongs_to :team
      t.integer :position
    end
    add_column :players, :team_names, :text, default: [], array: true

    ENV['NO_DISCORD'] = '1'
    Player.find_each do |player|
      player.location_ids = [player['location_id']]
      player.team_ids = [player['team_id']]
      player.save!
    end
    ENV['NO_DISCORD'] = '0'
  end
end
