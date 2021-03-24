class AddParentToPages < ActiveRecord::Migration[6.0]
  def change
    add_reference :pages, :parent, index: true
    add_foreign_key :pages, :pages, column: :parent_id
  end
end
