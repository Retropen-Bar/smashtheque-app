namespace :pg_search do

  namespace :multisearch do

    desc 'Rebuild all'
    task :rebuild_all => :environment do

      PgSearch::Document.delete_all
      [
        Character,
        Locations::City,
        Locations::Country,
        Player,
        Team
      ].each do |klass|
        puts "Rebuild multisearch for class #{klass}"
        PgSearch::Multisearch.rebuild(klass, false)
      end

    end

  end

end
