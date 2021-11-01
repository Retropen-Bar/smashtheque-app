class CommunitiesController < PublicController
  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_name_like

  layout 'application_v2'

  def index
    @communities = apply_scopes(Community.order('LOWER(name)')).all
    @meta_title = 'Communautés'
  end

  def show
    @community = Community.find(params[:id]).decorate
    @meta_title = @community.name
    @meta_properties['og:type'] = 'profile'
    @meta_properties['og:image'] = @community.decorate.any_image_url

    @offline_top_8_players =
      Player.ranked_offline.with_track_records_offline_all_time.by_community_id(@community.id).order(
        :rank_offline_all_time
      ).limit(8)
        
    @community_recurring_tournaments = RecurringTournament.visible.recurring.not_archived.limit(3)
    @community_to = Player.recurring_tournament_contacts.by_community_id(@community.id).limit(3)
    community_players = Player.by_community_id(@community.id)
    @community_biggest_teams = community_players.map do |player|
                                  Team.find_by(id: player.teams)
                                end.compact.sort_by{ |team| team.players.count }.reverse!
  end
end
