class AddVideoChannels < ActiveRecord::Migration[6.0]
  def change
    create_table :you_tube_channels do |t|
      t.string :username, null: false
      t.boolean :is_french, null: false, default: false
      t.belongs_to :related, polymorphic: true
      t.text :description
      t.timestamps
    end
    add_index :you_tube_channels, :username, unique: true

    create_table :twitch_channels do |t|
      t.string :username, null: false
      t.boolean :is_french, null: false, default: false
      t.belongs_to :related, polymorphic: true
      t.text :description
      t.timestamps
    end
    add_index :twitch_channels, :username, unique: true
  end
end
