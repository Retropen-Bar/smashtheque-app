class CreatePlayerProblems < ActiveRecord::Migration[6.0]
  def change
    create_table :problems do |t|
      t.belongs_to :reporting_user,
                   null: false,
                   foreign_key: { to_table: :users },
                   index: true
      t.belongs_to :player, foreign_key: true, index: true
      t.belongs_to :duo, foreign_key: true, index: true
      t.belongs_to :recurring_tournament, foreign_key: true, index: true
      t.string :nature, null: false, index: true
      t.date :occurred_at, null: false, index: true
      t.text :details, null: false

      t.timestamps
    end
  end
end
