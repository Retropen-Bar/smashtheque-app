class AddTeamAdmins < ActiveRecord::Migration[6.0]
  def change
    create_table :team_admins do |t|
      t.belongs_to :team, null: false
      t.belongs_to :discord_user, null: false
      t.timestamps
    end
    add_index :team_admins, [:team_id, :discord_user_id], unique: true
  end
end
