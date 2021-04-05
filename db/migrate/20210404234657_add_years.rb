class AddYears < ActiveRecord::Migration[6.0]
  def change
    [2019, 2020, 2021].each do |year|
      add_column :players, "points_in_#{year}", :integer, default: 0, null: false
      add_column :players, "rank_in_#{year}", :integer
      add_column :duos, "points_in_#{year}", :integer, default: 0, null: false
      add_column :duos, "rank_in_#{year}", :integer
    end
  end
end
