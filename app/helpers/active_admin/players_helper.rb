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

  def player_teams_select_collection
    Team.order(:name).map do |team|
      [
        team.decorate.full_name,
        team.id
      ]
    end
  end

  def player_input(form, options = {})
    name = options.delete(:name) || :player
    value = options.delete(:value) || form.object.send(name)

    form.input  name,
                {
                  as: :select,
                  collection: [
                    [
                      value&.decorate&.name_and_old_names,
                      value&.id
                    ]
                  ],
                  input_html: {
                    data: {
                      select2: {
                        minimumInputLength: 2,
                        ajax: {
                          delay: 250,
                          url: autocomplete_players_path,
                          dataType: 'json'
                        },
                        placeholder: 'Nom du joueur',
                        allowClear: true
                      }
                    }
                  }
                }.deep_merge(options)
  end

  def players_input(form, options = {})
    name = options.delete(:name) || :players
    value = options.delete(:value) || form.object.send(name)

    form.input  name,
                {
                  as: :select,
                  collection: value.map do |player|
                    [
                      player.decorate.name_and_old_names,
                      player.id
                    ]
                  end,
                  input_html: {
                    multiple: true,
                    data: {
                      select2: {
                        minimumInputLength: 2,
                        ajax: {
                          delay: 250,
                          url: autocomplete_players_path,
                          dataType: 'json'
                        },
                        placeholder: 'Nom des joueurs'
                      }
                    }
                  }
                }.deep_merge(options)
  end

end
