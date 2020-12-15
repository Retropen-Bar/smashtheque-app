class TournamentEventDecorator < BaseDecorator

  def bracket_link
    return nil if bracket_url.blank?
    h.link_to bracket_url, bracket_url, target: '_blank'
  end

  def graph_image_tag(options = {})
    return nil unless model.graph.attached?
    url = model.graph.service_url
    h.image_tag_with_max_size url, options
  end

end
