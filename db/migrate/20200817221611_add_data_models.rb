class AddDataModels < ActiveRecord::Migration[6.0]
  def change

    create_table :characters do |t|
      t.string :icon
      t.string :name
    end

    create_table :cities do |t|
      t.string :icon
      t.string :name
    end

    create_table :teams do |t|
      t.string :name
      t.string :short_name
    end

    create_table :players do |t|
      t.belongs_to :city
      t.belongs_to :team
      t.string :name
    end

    create_table :characters_players do |t|
      t.belongs_to :character
      t.belongs_to :player
    end

  end
end
