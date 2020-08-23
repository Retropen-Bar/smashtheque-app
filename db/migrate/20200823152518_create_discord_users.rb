class CreateDiscordUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :discord_users do |t|
      t.string :discord_id
      t.string :username
      t.string :discriminator
      t.string :avatar
      t.timestamps
    end
    add_index :discord_users, :discord_id, unique: true

    add_belongs_to :players, :discord_user
    add_belongs_to :admin_users, :discord_user
  end
end
