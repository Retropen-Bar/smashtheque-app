class TournamentEventDecorator < BaseDecorator

  def graph_image_tag(options = {})
    return nil unless model.graph.attached?
    h.image_tag_with_max_size model.graph, options
  end

end
