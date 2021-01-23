class DuosController < PublicController

  decorates_assigned :duo

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  layout :select_layout

  def index
    @duos = duos Duo
  end

  def show
    @duo = Duo.find(params[:id])
    @rewards_counts = @duo.rewards_counts
    @duo_tournament_events = @duo.duo_tournament_events.order(date: :desc).decorate
    # main_character = @duo.characters.first&.decorate
    # if main_character
    #   @background_color = main_character.background_color
    #   @background_image_url = main_character.background_image_data_url
    #   @background_size = main_character.background_size || 128
    # end
  end

  def ranking_online
    @duos = apply_scopes(
      Duo.ranked.order(:rank)
    ).includes(
      player1: { user: :discord_user },
      player2: { user: :discord_user }
    )
    # main_character = @players.first.characters.first&.decorate
    # if main_character
    #   @background_color = main_character.background_color
    #   @background_image_url = main_character.background_image_data_url
    #   @background_size = main_character.background_size || 128
    # end
  end

  private

  def duos(base)
    @map = params[:map].to_i == 1
    apply_scopes(
      base.order("LOWER(name)")
    ).includes(
      player1: { user: :discord_user },
      player2: { user: :discord_user }
    )
  end

  def select_layout
    @map ? 'map' : 'application'
  end

end
