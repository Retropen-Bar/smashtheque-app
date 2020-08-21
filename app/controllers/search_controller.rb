class SearchController < ApplicationController

  def global
    render json: {
      results: PgSearch.multisearch(params[:term]).map do |document|
        model = document.searchable.decorate
        {
          id: document.id,
          type: document.searchable_type,
          icon: model.icon_class,
          url: url_for([:admin, model.model]),
          html: model.as_autocomplete_result
        }
      end
    }
  end

end
