class SmashggEventDecorator < BaseDecorator

  def full_name
    [
      tournament_name,
      name
    ].join(' : ')
  end

  def full_name_with_icon(size: 32)
    [
      h.image_tag('https://smash.gg/images/gg-app-icon.png', height: size, style: "vertical-align: middle"),
      full_name
    ].join('&nbsp;').html_safe
  end

  def icon_class
    'smashgg'
  end

  def autocomplete_name
    full_name
  end

  def as_autocomplete_result
    h.content_tag :div, class: 'smashgg-event' do
      h.content_tag :div, class: :name do
        full_name_with_icon(size: 16)
      end
    end
  end

  def smashgg_link
    return nil if model.slug.blank?
    h.link_to smashgg_url, target: '_blank' do
      (
        h.image_tag 'https://smash.gg/images/gg-app-icon.png', height: 16, class: 'logo'
      ) + ' ' + (
        h.content_tag :span, model.name
      )
    end
  end

  def tournament_smashgg_link
    return nil if model.tournament_slug.blank?
    h.link_to tournament_smashgg_url, target: '_blank' do
      (
        h.image_tag 'https://smash.gg/images/gg-app-icon.png', height: 16, class: 'logo'
      ) + ' ' + (
        h.content_tag :span, model.tournament_name
      )
    end
  end

  def smashgg_user_rank_name(smashgg_user_id)
    user_name = smashgg_user_rank(smashgg_user_id)
    if user_name
      SmashggEvent.human_attribute_name("rank.#{user_name}")
    else
      nil
    end
  end

end
