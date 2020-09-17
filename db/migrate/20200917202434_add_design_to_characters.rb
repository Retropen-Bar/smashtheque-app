class AddDesignToCharacters < ActiveRecord::Migration[6.0]
  def change
    add_column :characters, :background_color, :string
    add_column :characters, :background_image, :text
  end
end
