# == Schema Information
#
# Table name: rewards
#
#  id         :bigint           not null, primary key
#  category   :string           not null
#  emoji      :string           not null
#  level1     :integer          not null
#  level2     :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_rewards_on_category_and_level1_and_level2  (category,level1,level2) UNIQUE
#
class Reward < ApplicationRecord

  CATEGORY_ONLINE_1V1 = 'online_1v1'.freeze
  CATEGORY_ONLINE_2V2 = 'online_2v2'.freeze
  CATEGORIES = [
    CATEGORY_ONLINE_1V1,
    CATEGORY_ONLINE_2V2
  ].freeze

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :reward_conditions, dependent: :destroy

  has_many :player_reward_conditions, through: :reward_conditions
  has_many :players, through: :player_reward_conditions

  has_many :reward_duo_conditions, dependent: :destroy

  has_many :duo_reward_duo_conditions, through: :reward_duo_conditions
  has_many :duos, through: :duo_reward_duo_conditions

  has_one_attached :image

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :category,
            presence: true,
            inclusion: {
              in: CATEGORIES
            }
  validates :level1,
            presence: true,
            numericality: {
              greater_than: 0
            }
  validates :level2,
            presence: true,
            numericality: {
              greater_than: 0
            },
            uniqueness: {
              scope: %i(category level1)
            }
  validates :image, content_type: /\Aimage\/.*\z/

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :by_category, -> v { where(category: v) }
  scope :by_level1, -> v { where(level1: v) }
  scope :by_level2, -> v { where(level2: v) }
  scope :by_level, -> (a, b) { where(level1: a, level2: b) }

  scope :online_1v1, -> { by_category(CATEGORY_ONLINE_1V1) }
  scope :online_2v2, -> { by_category(CATEGORY_ONLINE_2V2) }

  def self.ordered_by_level(asc = true)
    if asc
      order(:level1, :level2)
    else
      order(level1: :desc, level2: :desc)
    end
  end

  def self.grouped_by_level1
    ordered_by_level.group_by(&:level1).to_a
  end

  def self.grouped_by_level2
    ordered_by_level.group_by(&:level2).to_a
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def is_1v1?
    category.to_s == CATEGORY_ONLINE_1V1
  end
  def is_2v2?
    category.to_s == CATEGORY_ONLINE_2V2
  end

  def condition_name
    case category
    when CATEGORY_ONLINE_1V1
      :reward_condition
    when CATEGORY_ONLINE_2V2
      :reward_duo_condition
    end
  end
  def conditions_name
    condition_name.to_s.pluralize.to_sym
  end
  def conditions
    send(conditions_name)
  end

  def met_condition_name
    case category
    when CATEGORY_ONLINE_1V1
      :player_reward_condition
    when CATEGORY_ONLINE_2V2
      :duo_reward_duo_condition
    end
  end
  def met_conditions_name
    met_condition_name.to_s.pluralize.to_sym
  end
  def met_conditions
    send(met_conditions_name)
  end

  def awarded_name
    if is_1v1?
      :player
    else
      :duo
    end
  end
  def awardeds_name
    awarded_name.to_s.pluralize.to_sym
  end
  def awardeds
    send(awardeds_name)
  end

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
