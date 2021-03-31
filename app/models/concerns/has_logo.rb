module HasLogo
  extend ActiveSupport::Concern

  included do

    # ---------------------------------------------------------------------------
    # RELATIONS
    # ---------------------------------------------------------------------------

    has_one_attached :logo

    # ---------------------------------------------------------------------------
    # VALIDATIONS
    # ---------------------------------------------------------------------------

    validates :logo, content_type: /\Aimage\/.*\z/

    # ---------------------------------------------------------------------------
    # HELPERS
    # ---------------------------------------------------------------------------

    def logo_url
      return nil unless logo.attached?
      logo.service_url
    end

    def logo_url=(url)
      return false if url.blank?
      uri = URI.parse(url)
      open(url) do |f|
        logo.attach(io: File.open(f.path), filename: File.basename(uri.path))
      end
    end

  end

end
