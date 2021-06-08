class Api::V1::SearchController < Api::V1::BaseController

  skip_before_action :authenticate_request!

  def global
    render json: {
      results: PgSearch.multisearch(params[:term])
                       .where.not(searchable_type: %i(
                         BraacketTournament
                         ChallongeTournament
                         SmashggEvent
                       ))
                       .map do |document|
        model = document.searchable.decorate
        if document.searchable_type == 'Player' && !document.searchable.is_accepted?
          nil
        elsif document.searchable_type == 'RecurringTournament' && document.searchable.is_hidden?
          nil
        elsif document.searchable_type == 'TournamentEvent' && (
          document.searchable.recurring_tournament&.is_hidden?
        )
          nil
        elsif document.searchable_type == 'DuoTournamentEvent' && (
          document.searchable.recurring_tournament&.is_hidden?
        )
          nil
        else
          {
            id: document.id,
            type: document.searchable_type,
            icon: model.icon_class,
            url: url_for(model.model),
            html: model.as_autocomplete_result
          }
        end
      end.compact
    }
  end

end
