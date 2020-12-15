class TournamentEventDecorator < BaseDecorator

  def graph_image_tag(options = {})
    return nil unless model.graph.attached?
    url = model.graph.service_url
    h.image_tag_with_max_size url, options
  end

end
