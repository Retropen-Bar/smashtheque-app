class AddDataToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :is_draft, :boolean, null: false, default: false
    add_column :pages, :in_header, :boolean, null: false, default: false
    add_column :pages, :in_footer, :boolean, null: false, default: false
  end
end
