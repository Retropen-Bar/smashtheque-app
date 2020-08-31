ActiveAdmin.register_page 'Search' do
  menu false

  controller do
    def index
      render json: {
        results: PgSearch.multisearch(params[:term]).map do |document|
          model = if document.searchable_type == 'Location'
            # hack for weird bug
            Location.find(document.searchable_id).decorate
          else
            document.searchable.decorate
          end
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

end
