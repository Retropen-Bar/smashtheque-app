module ActiveAdmin
  class RewardDecorator < RewardDecorator
    include ActiveAdmin::BaseDecorator

    CATEGORY_COLORS = {
      Reward::CATEGORY_ONLINE_1V1.to_sym => :green,
      Reward::CATEGORY_ONLINE_2V2.to_sym => :blue,
      Reward::CATEGORY_OFFLINE_1V1.to_sym => :red,
      Reward::CATEGORY_OFFLINE_2V2.to_sym => :yellow
    }.freeze

    decorates :reward

    def admin_link(options = {}, badge_options = {})
      super({ label: badge(badge_options) }.merge(options))
    end

    def reward_conditions_admin_path
      admin_reward_conditions_path(q: { reward_id_in: [model.id] })
    end

    def reward_conditions_admin_link
      h.link_to reward_conditions_count, reward_conditions_admin_path
    end

    def met_reward_conditions_admin_path
      admin_met_reward_conditions_path(
        q: {
          reward_condition_reward_id_in: [model.id]
        }
      )
    end

    def met_reward_conditions_admin_link
      h.link_to met_reward_conditions_count, met_reward_conditions_admin_path
    end

    # def players_admin_path
    #   admin_players_path(
    #     q: {
    #       rewards_id_in: [model.id]
    #     }
    #   )
    # end

    # def players_admin_link
    #   h.link_to players_count, players_admin_path
    # end

    # def duos_admin_path
    #   admin_duos_path(
    #     q: {
    #       rewards_id_in: [model.id]
    #     }
    #   )
    # end

    # def duos_admin_link
    #   h.link_to duos_count, duos_admin_path
    # end

    def awardeds_admin_path
      h.polymorphic_path(
        [:admin, awardeds_name],
        q: {
          rewards_id_in: [model.id]
        }
      )
    end

    def awardeds_admin_link
      h.link_to awardeds_count, awardeds_admin_path
    end

    def category_status
      return nil if category.blank?

      arbre do
        status_tag category_name, class: CATEGORY_COLORS[category.to_sym]
      end
    end
  end
end
