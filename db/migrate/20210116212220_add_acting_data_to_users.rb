class AddActingDataToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_caster, :boolean, null: false, default: false

    add_column :users, :is_coach, :boolean, null: false, default: false
    add_column :users, :coaching_url, :string
    add_column :users, :coaching_details, :string
  end
end
