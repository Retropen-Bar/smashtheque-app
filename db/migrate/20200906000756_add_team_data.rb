class AddTeamData < ActiveRecord::Migration[6.0]
  def change
    add_column :teams, :logo_url, :string
    add_column :teams, :is_offline, :boolean
    add_column :teams, :is_online, :boolean
    add_column :teams, :is_sponsor, :boolean
  end
end
