# Provides helpers about points
module HasPoints
  extend ActiveSupport::Concern

  included do

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
      Player::POINTS_YEARS.each do |year|
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

  end
end
