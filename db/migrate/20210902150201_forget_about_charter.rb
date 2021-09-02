class ForgetAboutCharter < ActiveRecord::Migration[6.0]
  def change
    drop_table :problems
    remove_column :recurring_tournaments, :signed_charter_at
    remove_column :recurring_tournaments, :charter_signer_user_id
  end
end
