module ActiveAdmin::DiscordGuildsHelper

  def discord_guild_related_global_select_collection
    characters = Character.order(:name).map do |character|
      [
        character.decorate.pretty_name,
        character.to_global_id.to_s
      ]
    end
    teams = Team.order(:name).map do |team|
      [
        team.decorate.full_name,
        team.to_global_id.to_s
      ]
    end
    cities = Locations::City.order(:name).map do |city|
      [
        city.decorate.full_name,
        city.to_global_id.to_s
      ]
    end
    countries = Locations::Country.order(:name).map do |country|
      [
        country.decorate.full_name,
        country.to_global_id.to_s
      ]
    end
    {
      'Persos' => characters,
      'Équipes' => teams,
      'Villes' => cities,
      'Pays' => countries
    }
  end

end
