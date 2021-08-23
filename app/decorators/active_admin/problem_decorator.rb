module ActiveAdmin
  class ProblemDecorator < ProblemDecorator
    include ActiveAdmin::BaseDecorator

    decorates :problem

    def name
      [
        concerned_name,
        recurring_tournament&.name
      ].reject(&:blank?).join(' @ ')
    end

    def player_admin_link(options = {})
      player&.admin_decorate&.admin_link(options)
    end

    def duo_admin_link(options = {})
      duo&.admin_decorate&.admin_link(options)
    end

    def recurring_tournament_admin_link(options = {})
      recurring_tournament&.admin_decorate&.admin_link(options)
    end

    def reporting_user_admin_link(options = {})
      reporting_user&.admin_decorate&.admin_link(options)
    end

    def formatted_details
      h.tag.div model.details, class: 'free-text'
    end

    def occurred_at
      h.l model.occurred_at, format: :default
    end
  end
end
