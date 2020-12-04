require 'smashtheque_api'

namespace :dev do

  desc 'Import characters'
  task :import_characters => :environment do
    raise "not in development" unless Rails.env.development?
    raise "some characters exist" if Character.any?
    SmashthequeApi.characters.each do |data|
      data.delete('id')
      Character.new(data).save!
    end
  end

end
