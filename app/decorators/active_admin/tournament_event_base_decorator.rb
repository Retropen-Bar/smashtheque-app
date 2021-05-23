module ActiveAdmin
  module TournamentEventBaseDecorator
    include ActiveAdmin::BaseDecorator

    def recurring_tournament_admin_link(options = {})
      recurring_tournament&.admin_decorate&.admin_link(options)
    end

    def bracket_admin_link(options = {})
      bracket&.admin_decorate&.admin_link(options)
    end

    def admin_link(options = {})
      super({ label: name_with_logo(32) }.merge(options))
    end

    def first_event_admin_link(options = {})
      event = first_event
      if event
        event.admin_decorate.admin_link(options)
      else
        h.link_to options[:label], '#', class: 'disabled'
      end
    end

    def previous_event_admin_link(options = {})
      event = previous_event
      if event
        event.admin_decorate.admin_link(options)
      else
        h.link_to options[:label], '#', class: 'disabled'
      end
    end

    def next_event_admin_link(options = {})
      event = next_event
      if event
        event.admin_decorate.admin_link(options)
      else
        h.link_to options[:label], '#', class: 'disabled'
      end
    end

    def last_event_admin_link(options = {})
      event = last_event
      if event
        event.admin_decorate.admin_link(options)
      else
        h.link_to options[:label], '#', class: 'disabled'
      end
    end

    def events_nav_links(options = {})
      [
        first_event_admin_link(label: '⇤'),
        previous_event_admin_link(label: '←'),
        next_event_admin_link(label: '→'),
        last_event_admin_link(label: '⇥')
      ].join(' ').html_safe
    end
  end
end
