module ActiveAdmin::PlayersHelper

  def player_creator_user_select_collection
    User.order(:name).decorate
  end

  def player_characters_select_collection
    Character.order(:name).map do |character|
      [
        character.decorate.pretty_name,
        character.id
      ]
    end
  end

  def player_locations_select_collection
    Location.order(:name).map do |location|
      [
        location.decorate.full_name,
        location.id
      ]
    end
  end

  def player_teams_select_collection
    Team.order(:name).map do |team|
      [
        team.decorate.full_name,
        team.id
      ]
    end
  end

  def player_input(form, name = :player, options = {})
    form.input  name,
                {
                  as: :select,
                  collection: [
                    [
                      form.object.send(name)&.name,
                      form.object.send(name)&.id
                    ]
                  ],
                  input_html: {
                    data: {
                      select2: {
                        minimumInputLength: 3,
                        ajax: {
                          delay: 250,
                          url: autocomplete_admin_players_path,
                          dataType: 'json'
                        },
                        placeholder: 'Nom du joueur',
                        allowClear: true
                      }
                    }
                  }
                }.deep_merge(options)
  end

end
