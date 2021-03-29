class RenameLocationsToCommunities < ActiveRecord::Migration[6.0]
  def change
    rename_table :locations, :communities
    PaperTrail::Version.where(item_type: 'Location').update_all(item_type: 'Community')
  end
end
