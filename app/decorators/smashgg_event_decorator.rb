class SmashggEventDecorator < BaseDecorator
  def full_name
    [
      tournament_name,
      name
    ].join(' : ')
  end

  def icon_and_full_name(size: 32)
    [
      h.image_tag('https://smash.gg/images/gg-app-icon.png', height: size, style: 'vertical-align: middle'),
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
    h.tag.div class: 'smashgg-event' do
      h.tag.div class: :name do
        icon_and_full_name(size: 16)
      end
    end
  end

  def smashgg_link
    return nil if model.slug.blank?

    h.link_to smashgg_url, target: '_blank', rel: :noopener do
      (
        h.image_tag 'https://smash.gg/images/gg-app-icon.png', height: 16, class: 'logo'
      ) + ' ' + (
        h.tag.span model.name
      )
    end
  end

  def tournament_smashgg_link
    return nil if model.tournament_slug.blank?

    h.link_to tournament_smashgg_url, target: '_blank', rel: :noopener do
      (
        h.image_tag 'https://smash.gg/images/gg-app-icon.png', height: 16, class: 'logo'
      ) + ' ' + (
        h.tag.span model.tournament_name
      )
    end
  end

  def smashgg_user_rank_name(smashgg_user_id)
    user_name = smashgg_user_rank(smashgg_user_id)
    return SmashggEvent.human_attribute_name("rank.#{user_name}") if user_name

    nil
  end
end
