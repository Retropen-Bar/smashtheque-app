class RetropenBotJobs::RebuildLocationsForLocationJob < ApplicationJob
  queue_as :locations

  def perform(location, cities_category_id: nil, countries_category_id: nil)
    RetropenBot.default.rebuild_locations_for_location(
      location,
      cities_category_id: cities_category_id,
      countries_category_id: countries_category_id
    )
  end
end
