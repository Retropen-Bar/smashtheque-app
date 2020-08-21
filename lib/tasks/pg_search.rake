namespace :pg_search do

  namespace :multisearch do

    desc 'Rebuild all'
    task :rebuild_all => :environment do

      [
        Character,
        City,
        Player,
        Team
      ].each do |klass|
        puts "Rebuild multisearch for class #{klass}"
        PgSearch::Multisearch.rebuild(klass)
      end

    end

  end

end
