class CharactersController < PublicController
  has_scope :by_emoji

  layout 'application_v2'

  decorates_assigned :character

  def index
    @characters = apply_scopes(Character.order("lower(name)")).all
    @meta_title = 'Personnages'
  end

  def show
    @character = Character.find(params[:id]).decorate
    @meta_title = @character.name.titleize

    @online_top_5_players =
      Player.ranked_online.with_track_records_online_all_time.by_main_character_id(@character.id).order(
        :rank_online_all_time
      ).limit(5)

    @offline_top_5_players =
      Player.ranked_offline.with_track_records_offline_all_time.by_main_character_id(@character.id).order(
        :rank_offline_all_time
      ).limit(5)
  end
end
