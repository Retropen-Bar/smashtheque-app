class ChallongeTournamentDecorator < BaseDecorator
  def name_with_icon(size: 32)
    [
      h.image_tag(
        'https://assets.challonge.com/assets/challonge_fireball_orange-a973ff3b12c34c780fc21313ec71aada3b9b779cbd3a62769e9199ce08395692.svg',
        height: size,
        style: 'vertical-align: middle'
      ),
      name
    ].join('&nbsp;').html_safe
  end

  def challonge_link
    return nil if model.slug.blank?

    h.link_to challonge_url, target: '_blank', rel: :noopener do
      (
        h.image_tag(
          'https://assets.challonge.com/assets/challonge_fireball_orange-a973ff3b12c34c780fc21313ec71aada3b9b779cbd3a62769e9199ce08395692.svg',
          height: 16,
          class: 'logo'
        )
      ) + ' ' + (
        h.tag.span model.name
      )
    end
  end

  def icon_class
    'challonge'
  end

  def autocomplete_name
    model.name
  end

  def as_autocomplete_result
    h.tag.div class: 'challonge-tournament' do
      h.tag.div class: :name do
        name_with_icon(size: 16)
      end
    end
  end
end
