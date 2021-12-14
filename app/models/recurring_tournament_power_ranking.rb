# == Schema Information
#
# Table name: recurring_tournament_power_rankings
#
#  id                      :bigint           not null, primary key
#  name                    :string           not null
#  url                     :string           not null
#  year                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  recurring_tournament_id :bigint           not null
#
# Indexes
#
#  index_rtpr_rt_id  (recurring_tournament_id)
#
# Foreign Keys
#
#  fk_rails_...  (recurring_tournament_id => recurring_tournaments.id)
#
class RecurringTournamentPowerRanking < ApplicationRecord
  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :recurring_tournament

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :name, presence: true
  validates :url, presence: true
end
