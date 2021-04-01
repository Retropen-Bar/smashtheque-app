# == Schema Information
#
# Table name: players_recurring_tournaments
#
#  id                      :bigint           not null, primary key
#  has_good_network        :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  certifier_user_id       :bigint
#  player_id               :bigint
#  recurring_tournament_id :bigint
#
# Indexes
#
#  index_players_recurring_tournaments_on_certifier_user_id        (certifier_user_id)
#  index_players_recurring_tournaments_on_player_id                (player_id)
#  index_players_recurring_tournaments_on_recurring_tournament_id  (recurring_tournament_id)
#  index_prt_on_both_ids                                           (player_id,recurring_tournament_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (certifier_user_id => users.id)
#  fk_rails_...  (player_id => players.id)
#  fk_rails_...  (recurring_tournament_id => recurring_tournaments.id)
#
class PlayersRecurringTournament < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :player
  belongs_to :recurring_tournament
  belongs_to :certifier_user, class_name: :User, optional: true

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :recurring_tournament_id, uniqueness: { scope: :player_id }

end
