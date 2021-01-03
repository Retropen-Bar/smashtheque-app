class AddDataToCharacters < ActiveRecord::Migration[6.0]
  def change
    add_column :characters, :ultimateframedata_url, :string
    add_column :characters, :smashprotips_url, :string
  end
end
