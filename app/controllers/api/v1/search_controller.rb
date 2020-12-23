class Api::V1::SearchController < Api::V1::BaseController

  skip_before_action :authenticate_request!

  def global
    render json: {
      results: PgSearch.multisearch(params[:term])
                       .map do |document|
        model = if document.searchable_type == 'Location'
          # hack for weird bug
          Location.find(document.searchable_id).decorate
        else
          document.searchable.decorate
        end
        if document.searchable_type == 'Player' && !document.searchable.is_accepted?
          nil
        else
          url = if model.model.is_a?(Location)
            location_url(model.model)
          else
            url_for(model.model)
          end
          {
            id: document.id,
            type: document.searchable_type,
            icon: model.icon_class,
            url: url,
            html: model.as_autocomplete_result
          }
        end
      end.compact
    }
  end

end
