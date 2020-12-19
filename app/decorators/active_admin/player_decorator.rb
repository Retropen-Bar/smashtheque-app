class ActiveAdmin::PlayerDecorator < PlayerDecorator
  include ActiveAdmin::BaseDecorator

  decorates :player

  def indicated_name
    classes = []
    if !model.is_accepted? && model.potential_duplicates.any?
      classes << 'txt-error-underline'
    end
    h.content_tag :span, model.name, class: classes
  end

  def name_or_indicated_name
    if model.is_accepted?
      model.name
    else
      indicated_name
    end
  end

  def admin_link(options = {})
    super(options.merge(
      label: name_with_avatar(size: 32)
    ))
  end

  def characters_admin_links
    model.characters.map do |character|
      character.admin_decorate.admin_emoji_link
    end
  end

  def locations_admin_links
    model.locations.map do |location|
      location.admin_decorate.admin_link
    end
  end

  def teams_admin_links
    model.teams.map do |team|
      team.admin_decorate.admin_link
    end
  end

  def creator_admin_link(options = {})
    model.creator&.admin_decorate&.admin_link options
  end

  def discord_user_admin_link(options = {})
    model.discord_user&.admin_decorate&.admin_link options
  end

  def rewards_admin_links(options = {}, badge_options = {})
    rewards.admin_decorate.map do |reward|
      reward.admin_link(options, badge_options)
    end
  end

end
