class AddMoreCommunityData < ActiveRecord::Migration[6.0]
  def change
    change_table :communities, bulk: true do |t|
      t.string :ranking_url
      t.string :twitter_username
    end

    create_table :community_admins do |t|
      t.belongs_to :community, null: false, index: true
      t.belongs_to :user, null: false, index: true
      t.timestamps
    end
    add_index :community_admins, %i[community_id user_id], unique: true
  end
end
