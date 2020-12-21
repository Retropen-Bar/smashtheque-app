class DefaultPlayerPointsToZero < ActiveRecord::Migration[6.0]
  def change
    Player.where(points: nil).update_all(points: 0)
    change_column :players, :points, :integer, null: false, default: 0
  end
end
