module HasTrackRecords
  extend ActiveSupport::Concern

  included do
    # ---------------------------------------------------------------------------
    # RELATIONS
    # ---------------------------------------------------------------------------

    # each model is responsible for declaring how :met_reward_conditions are computed
    # e.g. has_many :met_reward_conditions, as: :awarded, dependent: :destroy
    has_many :reward_conditions, through: :met_reward_conditions
    has_many :rewards, through: :met_reward_conditions

    has_many :track_records, as: :tracked, dependent: :destroy

    # ---------------------------------------------------------------------------
    # SCOPES
    # ---------------------------------------------------------------------------

    def self.with_track_records(is_online:, year: nil)
      column_suffix = [
        is_online ? 'online' : 'offline',
        year ? "in_#{year}" : 'all_time'
      ].join('_')
      subquery = TrackRecord.by_tracked_type(self).by_is_online(is_online).on_year(year).select(
        :tracked_id,
        "points AS #{sanitize_sql("points_#{column_suffix}")}",
        "rank AS #{sanitize_sql("rank_#{column_suffix}")}"
      )
      joins(
        "LEFT OUTER JOIN (#{subquery.to_sql}) #{sanitize_sql("track_records_#{column_suffix}")}
                      ON #{table_name}.id = #{sanitize_sql("track_records_#{column_suffix}")}.tracked_id"
      )
    end

    def self.with_track_records_online_all_time
      with_track_records(is_online: true)
    end

    def self.with_track_records_online_in(year)
      with_track_records(is_online: true, year: year)
    end

    def self.with_track_records_offline_all_time
      with_track_records(is_online: false)
    end

    def self.with_track_records_offline_in(year)
      with_track_records(is_online: false, year: year)
    end

    def self.with_all_track_records
      result = with_track_records_online_all_time.with_track_records_offline_all_time
      TrackRecord.points_years.each do |year|
        result = result.with_track_records_online_in(year).with_track_records_offline_in(year)
      end
      result
    end

    def self.ranked_online_in(year)
      where(id: TrackRecord.online.on_year(year).by_tracked_type(self).select(:tracked_id))
    end

    def self.ranked_offline_in(year)
      where(id: TrackRecord.offline.on_year(year).by_tracked_type(self).select(:tracked_id))
    end

    scope :ranked_online, -> { ranked_online_in(nil) }
    scope :ranked_offline, -> { ranked_offline_in(nil) }

    # ---------------------------------------------------------------------------
    # HELPERS
    # ---------------------------------------------------------------------------

    def points_online_all_time
      track_records.online.all_time.first&.points || 0
    end

    def points_online_in(year)
      track_records.online.on_year(year).first&.points || 0
    end

    def points_offline_all_time
      track_records.offline.all_time.first&.points || 0
    end

    def points_offline_in(year)
      track_records.offline.on_year(year).first&.points || 0
    end

    def points(is_online:, year: nil)
      if is_online
        year ? points_online_in(year) : points_online_all_time
      else
        year ? points_offline_in(year) : points_offline_all_time
      end
    end

    def rank_online_all_time
      track_records.online.all_time.first&.rank
    end

    def rank_online_in(year)
      track_records.online.on_year(year).first&.rank
    end

    def rank_offline_all_time
      track_records.offline.all_time.first&.rank
    end

    def rank_offline_in(year)
      track_records.offline.on_year(year).first&.rank
    end

    def rank(is_online:, year: nil)
      if is_online
        year ? rank_online_in(year) : rank_online_all_time
      else
        year ? rank_offline_in(year) : rank_offline_all_time
      end
    end

    def best_met_reward_condition_online_all_time
      track_records.online.all_time.first&.best_met_reward_condition
    end

    def best_met_reward_condition_online_in(year)
      track_records.online.on_year(year).first&.best_met_reward_condition
    end

    def best_met_reward_condition_offline_all_time
      track_records.offline.all_time.first&.best_met_reward_condition
    end

    def best_met_reward_condition_offline_in(year)
      track_records.offline.on_year(year).first&.best_met_reward_condition
    end

    def best_met_reward_condition(is_online:, year: nil)
      if is_online
        year ? best_met_reward_condition_online_in(year) : best_met_reward_condition_online_all_time
      else
        year ? best_met_reward_condition_offline_in(year) : best_met_reward_condition_offline_all_time
      end
    end

    def best_reward_condition(is_online:, year: nil)
      best_met_reward_condition(is_online: is_online, year: year)&.reward_condition
    end

    def best_reward(is_online:, year: nil)
      best_reward_condition(is_online: is_online, year: year)&.reward
    end

    def update_track_record!(is_online:, year:)
      mrcs = met_reward_conditions.by_is_online(is_online)
      mrcs = mrcs.on_year(year) if year
      points_total = mrcs.points_total
      track_record = track_records.by_is_online(is_online).on_year(year).first_or_initialize
      if points_total.positive?
        track_record.points = points_total
        track_record.update_best_rewards
        puts track_record.errors.full_messages unless track_record.valid?
        track_record.save!
      elsif track_record.persisted?
        track_record.destroy
      end
    end

    def update_track_records!
      [false, true].each do |is_online|
        ([nil] + TrackRecord.points_years).each do |year|
          update_track_record!(is_online: is_online, year: year)
        end
      end
    end

    def all_rewards(is_online:)
      if is_online
        rewards.online
      else
        rewards.offline
      end
    end

    # returns a hash { reward_id => count }
    def rewards_counts(is_online:)
      all_rewards(is_online: is_online).ordered_by_level.group(:id).count
    end

    def self.ranking(is_online:, year: nil)
      if is_online
        if year
          ranked_online_in(year).with_track_records_online_in(year).order(
            "rank_online_in_#{year}".to_sym
          )
        else
          ranked_online.with_track_records_online_all_time.order(
            :rank_online_all_time
          )
        end
      elsif year
        ranked_offline_in(year).with_track_records_offline_in(year).order(
          "rank_offline_in_#{year}".to_sym
        )
      else
        ranked_offline.with_track_records_offline_all_time.order(
          :rank_offline_all_time
        )
      end
    end
  end
end
