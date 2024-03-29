module ActiveAdmin
  module CommunitiesHelper
    def community_countrycodes_select_collection
      Community.pluck('DISTINCT countrycode').reject(&:blank?).sort.map do |code|
        [
          ISO3166::Country.new(code)&.translation('fr') || code,
          code
        ]
      end
    end

    def community_select_collection
      Community.order('LOWER(name)').pluck(:name, :id)
    end
  end
end
