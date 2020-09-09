module ActiveAdmin::RelatedHelper

  def related_input(form, options = {})
    form.input  :related_gid,
                {
                  as: :select,
                  collection: [
                    [
                      form.object.related&.decorate&.autocomplete_name,
                      form.object.related&.to_global_id&.to_s
                    ]
                  ],
                  input_html: {
                    data: {
                      select2: {
                        ajax: {
                          url: url_for([:related_autocomplete, :admin, form.object.class]),
                          dataType: 'json'
                        }
                      }
                    }
                  }
                }.deep_merge(options)
  end

end
