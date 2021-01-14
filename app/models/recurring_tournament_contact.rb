# == Schema Information
#
# Table name: recurring_tournament_contacts
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  recurring_tournament_id :bigint
#  user_id                 :integer
#
# Indexes
#
#  index_recurring_tournament_contacts_on_recurring_tournament_id  (recurring_tournament_id)
#  index_recurring_tournament_contacts_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class RecurringTournamentContact < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :recurring_tournament
  belongs_to :user

end
