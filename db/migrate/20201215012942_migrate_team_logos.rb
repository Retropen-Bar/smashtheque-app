class MigrateTeamLogos < ActiveRecord::Migration[6.0]
  def change
    remove_column :teams, :logo_url
  end
end
