class AddTournamentOwnerToSmashggEvents < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to  :smashgg_events,
                    :tournament_owner,
                    foreign_key: { to_table: :smashgg_users },
                    index: true
  end
end
