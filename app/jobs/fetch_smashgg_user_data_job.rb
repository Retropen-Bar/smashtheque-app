class FetchSmashggUserDataJob < ApplicationJob
  queue_as :smashgg

  def perform(smashgg_user)
    smashgg_user.fetch_smashgg_data
    smashgg_user.save
    sleep 1
  end
end
