module ActiveAdmin::DuosHelper

  def duo_input(form, name = :duo, options = {})
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
                          url: autocomplete_admin_duos_path,
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
