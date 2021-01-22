class CreateDuos < ActiveRecord::Migration[6.0]
  def change
    create_table :duos do |t|
      t.string :name, null: false
      t.belongs_to :player1, null: false, foreign_key: { to_table: :players }
      t.belongs_to :player2, null: false, foreign_key: { to_table: :players }
      t.timestamps
    end
    add_index :duos, :name
  end
end
