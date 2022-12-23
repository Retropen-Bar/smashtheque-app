class AddMoreDataToSmashggEvents < ActiveRecord::Migration[6.0]
  def change
    change_table :smashgg_events, bulk: true do |t|
      t.float :latitude
      t.float :longitude
      t.string :primary_contact_type
      t.string :primary_contact
      t.belongs_to :discord_guild, foreign_key: true, index: true
    end
  end
end
