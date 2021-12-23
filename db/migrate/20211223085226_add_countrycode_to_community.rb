class AddCountrycodeToCommunity < ActiveRecord::Migration[6.0]
  def change
    add_column :communities, :countrycode, :string
    add_index :communities, :countrycode
  end
end
