class AddTopsToSmashggEvents < ActiveRecord::Migration[6.0]
  def change
    %w(1 2 3 4 5a 5b 7a 7b).each do |x|
      add_reference :smashgg_events, "top#{x}_smashgg_user"
      add_foreign_key :smashgg_events, :smashgg_users, column: "top#{x}_smashgg_user_id"
    end
  end
end
