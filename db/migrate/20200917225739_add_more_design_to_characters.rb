class AddMoreDesignToCharacters < ActiveRecord::Migration[6.0]
  def change
    add_column :characters, :background_size, :integer
  end
end
