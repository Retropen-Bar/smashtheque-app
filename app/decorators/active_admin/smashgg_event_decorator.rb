class ActiveAdmin::SmashggEventDecorator < SmashggEventDecorator
  include ActiveAdmin::BaseDecorator

  decorates :smashgg_event

  def start_at_date
    return nil if model.start_at.nil?
    h.l model.start_at.to_date, format: :default
  end

  def admin_link(options = {})
    super({label: icon_and_full_name(size: 16)}.merge(options))
  end

  def tournament_event_admin_link(options = {})
    tournament_event&.admin_decorate&.admin_link(options)
  end

  def duo_tournament_event_admin_link(options = {})
    duo_tournament_event&.admin_decorate&.admin_link(options)
  end

  def any_tournament_event_admin_link(options = {})
   any_tournament_event&.admin_decorate&.admin_link(options)
  end

  SmashggEvent::USER_NAMES.each do |user_name|
    define_method "#{user_name}_admin_link" do
      send(user_name)&.admin_decorate&.admin_link
    end
  end

  def create_tournament_event_admin_path
    attributes = {
      name: tournament_name,
      date: start_at,
      participants_count: num_entrants,
      bracket_url: smashgg_url,
      bracket_gid: model.to_global_id.to_s
    }
    TournamentEvent::TOP_RANKS.each do |rank|
      player_name = "top#{rank}_player".to_sym
      user_name = "top#{rank}_smashgg_user".to_sym
      if player = send(user_name)&.player
        attributes["#{player_name}_id"] = player.id
      end
    end
    new_admin_tournament_event_path(tournament_event: attributes)
  end

  def create_duo_tournament_event_admin_path
    attributes = {
      name: tournament_name,
      date: start_at,
      participants_count: num_entrants,
      bracket_url: smashgg_url,
      bracket_gid: model.to_global_id.to_s
    }
    # TournamentEvent::TOP_RANKS.each do |rank|
    #   player_name = "top#{rank}_player".to_sym
    #   user_name = "top#{rank}_smashgg_user".to_sym
    #   if player = send(user_name)&.player
    #     attributes["#{player_name}_id"] = player.id
    #   end
    # end
    new_admin_duo_tournament_event_path(duo_tournament_event: attributes)
  end

end
