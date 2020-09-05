class AddDiscordGuilds < ActiveRecord::Migration[6.0]
  def change
    create_table :discord_guilds do |t|
      # Discord data
      t.string :discord_id
      t.string :name
      t.string :icon
      t.string :splash

      # Smashtheque data
      t.belongs_to :related, polymorphic: true
      t.string :invitation_url

      t.timestamps
    end
  end
end
