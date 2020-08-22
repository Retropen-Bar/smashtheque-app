class Api::V1::SearchController < Api::V1::BaseController

  skip_before_action :authenticate_request!

  def global
    render json: {
      results: PgSearch.multisearch(params[:term]).map do |document|
        model = document.searchable.decorate
        {
          id: document.id,
          type: document.searchable_type,
          icon: model.icon_class,
          url: url_for(model.model),
          html: model.as_autocomplete_result
        }
      end
    }
  end

end
