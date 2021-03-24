class UpdateAvailableBracketsJob < ApplicationJob
  queue_as :smashgg

  def perform
    TournamentEvent.update_available_brackets
  end
end
