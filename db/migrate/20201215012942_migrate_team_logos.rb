class MigrateTeamLogos < ActiveRecord::Migration[6.0]
  def change
    Team.find_each do |team|
      next if team.logo_url.blank?
      team.logo.attach(
        io: open(team.logo_url),
        filename: URI(team.logo_url).path.split('/').last
      )
    end
    remove_column :teams, :logo_url
  end
end
