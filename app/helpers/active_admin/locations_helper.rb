module ActiveAdmin::LocationsHelper

  def address_input(form, options = {})
    prefix = options.delete(:prefix) || ''
    (
      form.input  "#{prefix}address".to_sym,
                  as: :string,
                  input_html: {
                    data: {
                      maps_autocomplete: {
                        target: {
                          latitude: "#location-#{prefix}latitude",
                          longitude: "#location-#{prefix}longitude"
                        }
                      }.merge(options)
                    }
                  }
    ) + (
      form.input  "#{prefix}latitude".to_sym,
                  as: :hidden,
                  input_html: {
                    id: "location-#{prefix}latitude"
                  }
    ) + (
      form.input  "#{prefix}longitude".to_sym,
                  as: :hidden,
                  input_html: {
                    id: "location-#{prefix}longitude"
                  }
    )
  end

end
