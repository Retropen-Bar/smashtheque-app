module ActiveAdmin::PlayersHelper

  def player_creator_select_collection
    DiscordUser.order(:username).decorate
  end

  def player_discord_user_select_collection
    DiscordUser.known.order(:username)
  end

  def player_characters_select_collection
    Character.order(:name).map do |character|
      [
        character.decorate.pretty_name,
        character.id
      ]
    end
  end

  def player_location_select_collection
    Location.order(:name).map do |location|
      [
        location.decorate.full_name,
        location.id
      ]
    end
  end

  def player_team_select_collection
    Team.order(:name).map do |team|
      [
        team.decorate.full_name,
        team.id
      ]
    end
  end

end
