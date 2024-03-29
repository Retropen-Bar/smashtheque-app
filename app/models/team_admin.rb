# == Schema Information
#
# Table name: team_admins
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  team_id    :bigint           not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_team_admins_on_team_id              (team_id)
#  index_team_admins_on_team_id_and_user_id  (team_id,user_id) UNIQUE
#  index_team_admins_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#
class TeamAdmin < ApplicationRecord
  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :team
  belongs_to :user
end
