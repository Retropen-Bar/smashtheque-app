class CreateRewards < ActiveRecord::Migration[6.0]
  def change
    create_table :rewards do |t|
      t.string :name, null: false
      t.text :image, null: false
      t.text :style
      t.timestamps
    end

    create_table :reward_conditions do |t|
      t.belongs_to :reward
      t.integer :size_min, null: false
      t.integer :size_max, null: false
      t.string :level, null: false
      t.integer :rank, null: false
      t.integer :points, null: false
      t.timestamps
    end
  end
end
