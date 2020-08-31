class AddOtherMissingTimestamps < ActiveRecord::Migration[6.0]
  def change
    [:characters, :cities].each do |t|
      add_column t, :created_at, :datetime
      add_column t, :updated_at, :datetime
      change_column t, :created_at, :datetime, null: false
      change_column t, :updated_at, :datetime, null: false
    end
  end
end
