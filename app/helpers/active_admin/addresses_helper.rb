module ActiveAdmin::AddressesHelper

  def google_places_api_tag
    javascript_include_tag "https://maps.googleapis.com/maps/api/js?libraries=places&key=#{ENV['GOOGLE_MAPS_API_KEY']}"
  end

  def address_input(form, options = {})
    prefix = options.delete(:prefix) || ''
    (
      address_address_input(form, prefix, options)
    ) + (
      address_latitude_input(form, prefix)
    ) + (
      address_longitude_input(form, prefix)
    )
  end

  def address_address_input(form, prefix, options)
    form.input  "#{prefix}address".to_sym,
                as: :string,
                input_html: {
                  data: {
                    maps_autocomplete: {
                      target: {
                        latitude: "#address-#{prefix}latitude",
                        longitude: "#address-#{prefix}longitude"
                      }
                    }.merge(options)
                  }
                }
  end

  def address_latitude_input(form, prefix)
    form.input  "#{prefix}latitude".to_sym,
                as: :hidden,
                input_html: {
                  id: "address-#{prefix}latitude"
                }
  end

  def address_longitude_input(form, prefix)
    form.input  "#{prefix}longitude".to_sym,
                as: :hidden,
                input_html: {
                  id: "address-#{prefix}longitude"
                }
  end

end
