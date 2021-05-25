module HasTrackRecords
  extend ActiveSupport::Concern

  included do
    # ---------------------------------------------------------------------------
    # RELATIONS
    # ---------------------------------------------------------------------------

    has_many :met_reward_conditions, as: :awarded, dependent: :destroy
    has_many :reward_conditions, through: :met_reward_conditions
    has_many :rewards, through: :met_reward_conditions

    has_many :track_records, as: :tracked, dependent: :destroy

    # cache
    belongs_to :best_met_reward_condition,
               class_name: :MetRewardCondition,
               optional: true

    has_one :best_reward,
            through: :best_met_reward_condition,
            source: :reward

    # ---------------------------------------------------------------------------
    # SCOPES
    # ---------------------------------------------------------------------------

    # def self.tracked

    # end

    # scope :with_points, -> { where('points > 0') }
    # scope :with_points_in, ->(year) { where(sanitize_sql(['points_in_? > 0', year])) }
    # scope :ranked, -> { where.not(rank: nil) }
    # scope :ranked_in, ->(year) { where.not(sanitize_sql("rank_in_#{year}") => nil) }

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

    # returns a hash { reward_id => count }
    def rewards_counts
      rewards.ordered_by_level.group(:id).count
    end

    # def unique_rewards
    #   Reward.where(id: rewards.select(:id))
    # end

    # def best_rewards
    #   Hash[
    #     rewards.order(:level1).group(:level1).pluck(:level1, "MAX(level2)")
    #   ].map do |level1, level2|
    #     Reward.online_1v1.by_level(level1, level2).first
    #   end.sort_by(&:level2)
    # end
  end
end
