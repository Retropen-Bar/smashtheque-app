class UpdateTeamBooleanValues < ActiveRecord::Migration[6.0]
  def change
    %i[is_offline is_online is_sponsor is_recruiting].each do |attr|
      Team.where(attr => nil).update_all(attr => false)
      change_column :teams, attr, :boolean, null: false, default: false
    end
  end
end
