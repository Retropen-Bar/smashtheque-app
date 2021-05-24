module ActiveAdmin
  class PlayerDecorator < PlayerDecorator
    include ActiveAdmin::BaseDecorator
    include ActiveAdmin::HasTrackRecordsDecorator

    decorates :player

    def indicated_name
      classes = []
      classes << 'txt-error-underline' if !model.is_accepted? && model.potential_duplicates.any?
      h.tag.span model.name, class: classes
    end

    def name_or_indicated_name
      if model.is_accepted?
        model.name
      else
        indicated_name
      end
    end

    def old_names_list
      arbre do
        ul do
          old_names.each do |old_name|
            li old_name
          end
        end
      end
    end

    def admin_link(options = {})
      with_teams = options.delete(:with_teams)
      super({ label: name_with_avatar(size: 32, with_teams: with_teams) }.merge(options))
    end

    def characters_admin_links
      model.characters.map do |character|
        character.admin_decorate.admin_emoji_link
      end
    end

    def teams_admin_links
      model.teams.map do |team|
        team.admin_decorate.admin_link
      end
    end

    def teams_admin_short_links
      model.teams.admin_decorate.map do |team|
        team.admin_link(label: team.short_name_with_logo(size: 32))
      end
    end

    def creator_user_admin_link(options = {})
      model.creator_user&.admin_decorate&.admin_link options
    end

    def user_admin_link(options = {})
      model.user&.admin_decorate&.admin_link options
    end

    def smashgg_users_admin_links(options = {})
      model.smashgg_users.map do |smashgg_user|
        smashgg_user.admin_decorate.admin_link options.clone
      end
    end
  end
end
