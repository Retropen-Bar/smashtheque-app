class LinkRecurringTournamentsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :recurring_tournament_contacts, :user_id, :integer
    add_index :recurring_tournament_contacts, :user_id
    add_foreign_key :recurring_tournament_contacts, :users, column: :user_id
    RecurringTournamentContact.find_each do |rtc|
      next if rtc['discord_user_id'].nil?
      user_id = DiscordUser.find(rtc['discord_user_id'])
                           .return_or_create_user!
                           .id
      RecurringTournamentContact.where(id: rtc.id)
                                .update_all(user_id: user_id)
    end
    remove_column :recurring_tournament_contacts, :discord_user_id
  end
end
