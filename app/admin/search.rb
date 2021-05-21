ActiveAdmin.register_page 'Search' do
  menu false

  controller do
    def index
      results = {}
      PgSearch.multisearch(params[:term]).each do |document|
        model = document.searchable.decorate
        key = model.model_name.human.pluralize
        results[key] ||= []
        results[key] << {
          id: document.id,
          type: document.searchable_type,
          icon: model.icon_class,
          url: url_for([:admin, model.model]),
          html: model.as_autocomplete_result
        }
      end

      render json: {
        results: results.map do |klass, items|
          {
            text: "#{klass} (#{items.count})",
            children: items
          }
        end
      }
    end
  end

end
