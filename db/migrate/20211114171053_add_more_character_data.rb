class AddMoreCharacterData < ActiveRecord::Migration[6.0]
  def change
    change_table :characters, bulk: true do |t|
      t.string :origin
      t.string :nintendo_url
      t.string :other_names, default: [], array: true
    end
  end
end
