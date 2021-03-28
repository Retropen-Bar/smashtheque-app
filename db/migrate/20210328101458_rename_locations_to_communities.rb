class RenameLocationsToCommunities < ActiveRecord::Migration[6.0]
  def change
    rename_table :locations, :communities
  end
end
