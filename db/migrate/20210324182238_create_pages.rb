class CreatePages < ActiveRecord::Migration[6.0]
  def change
    create_table :pages do |t|
      t.string :slug, null: false
      t.string :name, null: false

      t.timestamps

      t.index :slug, unique: true
    end
  end
end
