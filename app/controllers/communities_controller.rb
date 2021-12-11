class CommunitiesController < PublicController
  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_name_like

  layout 'application_v2'

  decorates_assigned :community

  def index
    @communities = apply_scopes(Community.order('LOWER(name)')).all
    @meta_title = 'Communautés'
  end

  def map
    @communities = apply_scopes(Community)
    @meta_title = 'Carte des communautés'
  end

  def show
    @community = Community.find(params[:id]).decorate
    @meta_title = @community.name
    @meta_properties['og:type'] = 'profile'
    @meta_properties['og:image'] = @community.decorate.any_image_url

    @offline_top_8_players =
      Player.legit.ranked_offline.with_track_records_offline_all_time.by_community_id(@community.id).order(
        :rank_offline_all_time
      ).limit(8)

    # we cannot directly get a sorted relation here (yet), so we sort it manually
    @community_recurring_tournaments = RecurringTournament.visible.recurring.not_archived.offline
      .by_closest_community_id(@community.id).includes(:tournament_events, :duo_tournament_events).to_a
    @community_recurring_tournaments.sort_by! { |recurring_tournament| recurring_tournament.all_events.count }

    @community_tos = @community_recurring_tournaments.map(&:contacts).flatten.uniq

    @community_admins = @community.admins.to_a
  end
end
