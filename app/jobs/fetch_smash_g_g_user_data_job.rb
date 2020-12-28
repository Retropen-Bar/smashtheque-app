class FetchSmashGGUserDataJob < ApplicationJob
  queue_as :smashgg

  def perform(smash_gg_user)
    smash_gg_user.fetch_smashgg_data
    smash_gg_user.save!
    sleep 1
  end
end
