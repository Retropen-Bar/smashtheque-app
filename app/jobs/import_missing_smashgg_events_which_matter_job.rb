class ImportMissingSmashggEventsWhichMatterJob < ApplicationJob
  queue_as :smashgg

  def perform
    SmashggUser.import_missing_smashgg_events_which_matter
  end
end
