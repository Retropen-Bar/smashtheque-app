class CreateDuoRewardConditions < ActiveRecord::Migration[6.0]
  def change
    create_table :reward_duo_conditions do |t|
      t.belongs_to :reward, null: false, foreign_key: true, index: true
      t.integer :size_min, null: false
      t.integer :size_max, null: false
      t.integer :rank, null: false
      t.integer :points, null: false
      t.timestamps
    end

    create_table :duo_reward_duo_conditions do |t|
      t.belongs_to :duo, null: false, foreign_key: true, index: true
      t.belongs_to :reward_duo_condition, null: false, foreign_key: true, index: true
      t.belongs_to :duo_tournament_event, null: false, foreign_key: true, index: true
      t.timestamps
    end
    add_index :duo_reward_duo_conditions,
              %i(duo_id reward_duo_condition_id duo_tournament_event_id),
              name: :index_drdc_on_all,
              unique: true
  end
end
