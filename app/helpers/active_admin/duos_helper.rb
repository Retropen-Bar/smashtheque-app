module ActiveAdmin::DuosHelper

  def duo_input(form, options = {})
    name = options.delete(:name) || :player
    value = options.delete(:value) || form.object.send(name)

    form.input  name,
                {
                  as: :select,
                  collection: [
                    [
                      value&.decorate&.name_with_player_names,
                      value&.id
                    ]
                  ],
                  input_html: {
                    data: {
                      select2: {
                        minimumInputLength: 2,
                        ajax: {
                          delay: 250,
                          url: autocomplete_duos_path,
                          dataType: 'json'
                        },
                        placeholder: "Nom de l'équipe",
                        allowClear: true
                      }
                    }
                  }
                }.deep_merge(options)
  end

end
