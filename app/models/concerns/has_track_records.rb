module HasTrackRecords
  extend ActiveSupport::Concern

  included do
    # ---------------------------------------------------------------------------
    # RELATIONS
    # ---------------------------------------------------------------------------

    has_many :met_reward_conditions, as: :awarded, dependent: :destroy
    has_many :reward_conditions, through: :met_reward_conditions
    has_many :rewards, through: :met_reward_conditions

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

    scope :with_points, -> { where("points > 0") }
    scope :with_points_in, -> year { where(sanitize_sql(["points_in_? > 0", year])) }
    scope :ranked, -> { where.not(rank: nil) }
    scope :ranked_in, -> year { where.not(sanitize_sql("rank_in_#{year}") => nil) }

    scope :by_best_reward_level1, -> v { where(best_reward_level1: v) }
    scope :by_best_reward_level2, -> v { where(best_reward_level2: v) }
    def self.by_best_reward_level(a, b)
      by_best_reward_level1(a).by_best_reward_level2(b)
    end
    def self.by_best_reward(reward)
      by_best_reward_level(reward.level1, reward.level2)
    end

    # ---------------------------------------------------------------------------
    # HELPERS
    # ---------------------------------------------------------------------------

    def points_in(year)
      send("points_in_#{year}")
    end

    def rank_in(year)
      send("rank_in_#{year}")
    end

    def update_cache!
      update_points
      update_best_reward
      save!
    end

    def self.update_ranks!
      TrackRecord.points_years.each do |year|
        subquery =
          self.with_points_in(year)
              .select(
                :id,
                "ROW_NUMBER() OVER(ORDER BY #{sanitize_sql("points_in_#{year}")} DESC) AS newrank"
              )

        update_all("
          #{sanitize_sql("rank_in_#{year}")} = pointed.newrank
          FROM (#{subquery.to_sql}) pointed
          WHERE #{table_name}.id = pointed.id
        ")
        self.where.not(id: with_points_in(year).select(:id))
            .update_all(sanitize_sql("rank_in_#{year}") => nil)
      end

      subquery =
        self.with_points
            .select(:id, "ROW_NUMBER() OVER(ORDER BY points DESC) AS newrank")

      update_all("
        rank = pointed.newrank
        FROM (#{subquery.to_sql}) pointed
        WHERE #{table_name}.id = pointed.id
      ")
      self.where.not(id: with_points.select(:id))
          .update_all(rank: nil)
    end

    # returns a hash { reward_id => count }
    def rewards_counts
      rewards.ordered_by_level.group(:id).count
    end

    def unique_rewards
      Reward.where(id: rewards.select(:id))
    end

    def best_rewards
      Hash[
        rewards.order(:level1).group(:level1).pluck(:level1, "MAX(level2)")
      ].map do |level1, level2|
        Reward.online_1v1.by_level(level1, level2).first
      end.sort_by(&:level2)
    end

    # TODO POINTS
    def update_points
      TrackRecord.points_years.each do |year|
        self.attributes = {
          "points_in_#{year}" => (
            met_reward_conditions.on_year(year).points_total
          )
        }
      end
      self.points = met_reward_conditions.points_total
    end

    def update_best_reward
      met_reward_condition =
        met_reward_conditions.joins(:reward).order(:level1, :level2, :points).last
      self.best_met_reward_condition = met_reward_condition
      self.best_reward_level1 = met_reward_condition&.reward&.level1
      self.best_reward_level2 = met_reward_condition&.reward&.level2
    end
  end
end
