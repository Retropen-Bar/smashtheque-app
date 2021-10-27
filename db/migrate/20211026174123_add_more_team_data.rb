class AddMoreTeamData < ActiveRecord::Migration[6.0]
  def change
    change_table :teams, bulk: true do |t|
      t.string :website_url
      t.integer :creation_year
      t.boolean :is_recruiting
      t.text :recruiting_details
      t.text :description
    end
  end
end
