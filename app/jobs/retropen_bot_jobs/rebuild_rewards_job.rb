class RetropenBotJobs::RebuildRewardsJob < ApplicationJob
  queue_as :rewards

  def perform(rewards_category_id: nil)
    RetropenBot.default.rebuild_rewards(
      rewards_category_id
    )
  end
end
