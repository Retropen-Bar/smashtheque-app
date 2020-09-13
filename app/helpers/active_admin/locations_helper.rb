module ActiveAdmin::LocationsHelper

  def address_input(form, options = {})
    form.input  :address,
                as: :string,
                input_html: {
                  data: {
                    maps_autocomplete: {
                      target: {
                        latitude: '#location-latitude',
                        longitude: '#location-longitude'
                      }
                    }.merge(options)
                  }
                }
    form.input  :latitude,
                as: :hidden,
                input_html: {
                  id: 'location-latitude'
                }
    form.input  :longitude,
                as: :hidden,
                input_html: {
                  id: 'location-longitude'
                }
  end

end
