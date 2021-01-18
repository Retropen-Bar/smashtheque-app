class AddGraphicDesigners < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_graphic_designer, :boolean, null: false, default: false
    add_column :users, :graphic_designer_details, :string
    add_column :users, :is_available_graphic_designer, :boolean, null: false, default: false
  end
end
