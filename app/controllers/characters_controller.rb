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
      Player.ranked_online.with_track_records_online_all_time.by_main_character_id(
        @character.id
      ).by_main_countrycode_unknown_or_french_speaking.order(
        :rank_online_all_time
      ).legit.limit(5)

    @offline_top_5_players =
      Player.ranked_offline.with_track_records_offline_all_time.by_main_character_id(
        @character.id
      ).by_main_countrycode_unknown_or_french_speaking.order(
        :rank_offline_all_time
      ).legit.limit(5)

    @has_usesul_links = (
      @character.nintendo_url || @character.ultimateframedata_url || @character.smashprotips_url
    ).present?

    @you_tube_channels = @character.you_tube_channels.to_a
    @twitch_channels = @character.twitch_channels.to_a
  end
end
