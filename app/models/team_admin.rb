# == Schema Information
#
# Table name: team_admins
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  discord_user_id :bigint           not null
#  team_id         :bigint           not null
#
# Indexes
#
#  index_team_admins_on_discord_user_id              (discord_user_id)
#  index_team_admins_on_team_id                      (team_id)
#  index_team_admins_on_team_id_and_discord_user_id  (team_id,discord_user_id) UNIQUE
#
class TeamAdmin < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :team
  belongs_to :discord_user

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    RetropenBotScheduler.rebuild_team_admins_list
  end

end
