class CreateTrackRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :track_records do |t|
      t.belongs_to :tracked, polymorphic: true, null: false

      t.integer :year
      t.boolean :is_online, null: false, default: false
      t.integer :points, null: false
      t.integer :rank, null: false
      t.integer :best_met_reward_condition_id
      t.string :best_reward_level1
      t.string :best_reward_level2

      t.timestamps
    end
    add_index :track_records,
              %i[tracked_type tracked_id year is_online],
              name: :index_track_records_on_all,
              unique: true
    add_foreign_key :track_records,
                    :met_reward_conditions,
                    column: :best_met_reward_condition_id

    %i[duos players].each do |table_name|
      %i[
        points
        points_in_2019
        points_in_2020
        points_in_2021
      ].each do |column_name|
        remove_column table_name, column_name, :integer, default: 0, null: false
      end
      %i[
        rank
        rank_in_2019
        rank_in_2020
        rank_in_2021
      ].each do |column_name|
        remove_column table_name, column_name, :integer
      end
    end
  end
end
