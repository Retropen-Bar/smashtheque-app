class CreateSmashggUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :smashgg_users do |t|
      t.integer :smashgg_id, null: false
      t.string :slug, null: false

      # relations
      t.belongs_to :player

      # profile
      t.text :bio
      t.string :birthday
      t.string :gender_pronoun
      t.string :name
      t.string :city
      t.string :country
      t.string :country_id
      t.string :state
      t.string :state_id
      t.string :smashgg_player_id
      t.string :gamer_tag
      t.string :prefix
      t.string :banner_url
      t.string :avatar_url

      # links to other profiles
      t.string :discord_discriminated_username
      t.string :twitch_username
      t.string :twitter_username

      t.timestamps
    end
    add_index :smashgg_users, :smashgg_id, unique: true
    add_index :smashgg_users, :slug, unique: true
    add_foreign_key :smashgg_users, :players
  end
end
