module ActiveAdmin::AddressesHelper

  def address_input(form, options = {})
    prefix = options.delete(:prefix) || ''
    (
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
    ) + (
      form.input  "#{prefix}latitude".to_sym,
                  as: :hidden,
                  input_html: {
                    id: "address-#{prefix}latitude"
                  }
    ) + (
      form.input  "#{prefix}longitude".to_sym,
                  as: :hidden,
                  input_html: {
                    id: "address-#{prefix}longitude"
                  }
    )
  end

end
