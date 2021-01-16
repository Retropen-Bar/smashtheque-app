# == Schema Information
#
# Table name: team_admins
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  team_id    :bigint           not null
#  user_id    :integer
#
# Indexes
#
#  index_team_admins_on_team_id              (team_id)
#  index_team_admins_on_team_id_and_user_id  (team_id,user_id) UNIQUE
#  index_team_admins_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class TeamAdmin < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :team
  belongs_to :user

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    RetropenBotScheduler.rebuild_team_admins_list
  end

end
