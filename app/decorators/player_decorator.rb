class PlayerDecorator < BaseDecorator

  def indicated_name
    classes = []
    if !model.is_accepted? && model.potential_duplicates.any?
      classes << 'txt-error-underline'
    end
    h.content_tag :span, model.name, class: classes
  end

  def characters_links
    model.characters.map do |character|
      character.decorate.admin_emoji_link
    end
  end

  def location_link
    model.location&.decorate&.admin_link
  end

  def team_link
    model.team&.decorate&.admin_link
  end

  def creator_link(options = {})
    model.creator.decorate.admin_link options
  end

  def discord_user_admin_link(options = {})
    model.discord_user&.decorate&.admin_link options
  end

  def icon_class
    :user
  end

  def as_autocomplete_result
    h.content_tag :div, class: :player do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

end
