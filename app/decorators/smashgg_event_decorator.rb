class SmashggEventDecorator < BaseDecorator

  def full_name
    [
      tournament_name,
      name
    ].join(' : ')
  end

  def smashgg_link
    return nil if model.slug.blank?
    h.link_to "https://smash.gg/#{model.slug}", target: '_blank' do
      (
        h.image_tag 'https://smash.gg/images/gg-app-icon.png', height: 16, class: 'logo'
      ) + ' ' + (
        h.content_tag :span, model.slug
      )
    end
  end

end
