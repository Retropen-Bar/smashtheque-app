class Api::V1::SearchController < Api::V1::BaseController
  skip_before_action :authenticate_request!

  def global
    results = search_scope.filter_map do |document|
      use_document?(document) && render_document(document)
    end

    render json: {
      results: results
    }
  end

  private

  def search_scope
    search = PgSearch.multisearch(params[:term])
    if params[:by_type_in]
      search.where(
        searchable_type: params[:by_type_in]
      )
    else
      search.where.not(
        searchable_type: %i[
          BraacketTournament
          ChallongeTournament
          SmashggEvent
        ]
      )
    end
  end

  def use_document?(document)
    model = document.searchable
    return false if model.nil?

    case document.searchable_type
    when 'Player'
      model.is_legit?
    when 'RecurringTournament'
      !model.is_hidden?
    when 'TournamentEvent', 'DuoTournamentEvent'
      !model.recurring_tournament&.is_hidden?
    else
      true
    end
  end

  def render_document(document)
    model = document.searchable.decorate

    {
      id: model.id,
      type: document.searchable_type,
      icon: model.icon_class,
      url: url_for(model.model),
      html: model.as_autocomplete_result
    }
  end
end
