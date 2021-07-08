module RetropenBotJobs
  class UpdateMemberRolesJob < ApplicationJob
    queue_as :discord

    def perform(discord_id: nil)
      RetropenBot.default.update_member_roles(discord_id)
    end
  end
end
