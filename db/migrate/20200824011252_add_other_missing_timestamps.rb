class AddOtherMissingTimestamps < ActiveRecord::Migration[6.0]
  def change
    [Character, City].each do |klass|
      t = klass.table_name
      add_column t, :created_at, :datetime
      add_column t, :updated_at, :datetime
      klass.update_all(
        created_at: Time.now,
        updated_at: Time.now
      )
      change_column t, :created_at, :datetime, null: false
      change_column t, :updated_at, :datetime, null: false
    end
  end
end
