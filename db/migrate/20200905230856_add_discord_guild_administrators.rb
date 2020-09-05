class AddDiscordGuildAdministrators < ActiveRecord::Migration[6.0]
  def change
    create_table :discord_guild_admins do |t|
      t.belongs_to :discord_guild, null: false
      t.belongs_to :discord_user, null: false
      t.string :role
      t.timestamps
    end
    add_index :discord_guild_admins,
              [:discord_guild_id, :discord_user_id],
              unique: true,
              name: 'index_dga_on_both_ids'
  end
end
