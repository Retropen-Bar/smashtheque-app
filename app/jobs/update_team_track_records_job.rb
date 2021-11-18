class UpdateTeamTrackRecordsJob < ApplicationJob
  queue_as :track_records

  def perform(team)
    team.update_track_records!
    TrackRecord.update_all_ranks!(Team)
  end
end
