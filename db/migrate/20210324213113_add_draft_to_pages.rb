class AddDraftToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :is_draft, :boolean, null: false, default: false
  end
end
