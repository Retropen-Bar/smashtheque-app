# == Schema Information
#
# Table name: recurring_tournament_contacts
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  recurring_tournament_id :integer          not null
#  user_id                 :integer          not null
#
# Indexes
#
#  index_recurring_tournament_contacts_on_recurring_tournament_id  (recurring_tournament_id)
#  index_recurring_tournament_contacts_on_user_id                  (user_id)
#  index_rtc_on_both_ids                                           (recurring_tournament_id,user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (recurring_tournament_id => recurring_tournaments.id)
#  fk_rails_...  (user_id => users.id)
#
class RecurringTournamentContact < ApplicationRecord
  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :recurring_tournament
  belongs_to :user

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord_user_discord_roles, unless: proc { ENV['NO_DISCORD'] }
  def update_discord_user_discord_roles
    user&.discord_user&.update_discord_roles
  end
end
