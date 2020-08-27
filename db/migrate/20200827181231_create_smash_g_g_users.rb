class CreateSmashGGUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :smash_gg_users do |t|
      t.integer :smashgg_id, null: false

      # relations
      t.belongs_to :discord_user

      # smash.gg profile
      t.text :bio
      t.string :birthday
      t.string :gender_pronoun
      t.string :name
      t.string :slug
      t.string :city
      t.string :country
      t.string :country_id
      t.string :state
      t.string :state_id
      t.string :player_id
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
    add_index :smash_gg_users, :smashgg_id, unique: true

    add_belongs_to :players, :smash_gg_user
  end
end
