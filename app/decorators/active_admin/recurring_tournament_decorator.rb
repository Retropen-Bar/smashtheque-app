module ActiveAdmin
  class RecurringTournamentDecorator < RecurringTournamentDecorator
    include ActiveAdmin::BaseDecorator

    decorates :recurring_tournament

    def admin_link(options = {})
      super({ label: name_with_logo(max_width: 32, max_height: 32) }.merge(options))
    end

    def closest_community_admin_link(options = {})
      closest_community&.admin_decorate&.admin_link(options)
    end

    def tournament_events_admin_link
      h.link_to(
        tournament_events_count,
        admin_tournament_events_path(
          q: {
            recurring_tournament_id_eq: model.id
          }
        )
      )
    end

    def duo_tournament_events_admin_link
      h.link_to(
        duo_tournament_events_count,
        admin_duo_tournament_events_path(
          q: {
            recurring_tournament_id_eq: model.id
          }
        )
      )
    end

    def contacts_admin_links(options = {})
      model.contacts.map do |user|
        user.admin_decorate.admin_link(options)
      end
    end

    def level_status
      arbre do
        status_tag level_text, class: LEVEL_COLORS[model.level.to_sym]
      end
    end

    def short_level_status
      arbre do
        status_tag short_level_text, class: LEVEL_COLORS[model.level.to_sym]
      end
    end

    def discord_guild_admin_link(options = {})
      model.discord_guild&.admin_decorate&.admin_link(options)
    end
  end
end
