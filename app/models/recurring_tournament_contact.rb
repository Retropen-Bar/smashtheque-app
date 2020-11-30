# == Schema Information
#
# Table name: recurring_tournament_contacts
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  discord_user_id         :bigint
#  recurring_tournament_id :bigint
#
# Indexes
#
#  index_recurring_tournament_contacts_on_discord_user_id          (discord_user_id)
#  index_recurring_tournament_contacts_on_recurring_tournament_id  (recurring_tournament_id)
#  index_rtc_on_both_ids                                           (recurring_tournament_id,discord_user_id) UNIQUE
#
class RecurringTournamentContact < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :recurring_tournament
  belongs_to :discord_user

end
