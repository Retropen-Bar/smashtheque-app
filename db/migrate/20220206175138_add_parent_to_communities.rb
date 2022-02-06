class AddParentToCommunities < ActiveRecord::Migration[6.0]
  def change
    add_reference :communities, :parent, index: true
    add_foreign_key :communities, :communities, column: :parent_id
  end
end
