namespace :retropen do

  desc 'Rebuild ABC'
  task :rebuild_abc => :environment do
    RetropenBot.default.rebuild_abc
  end

  desc 'Rebuild chars'
  task :rebuild_chars => :environment do
    RetropenBot.default.rebuild_chars
  end

  desc 'Rebuild cities'
  task :rebuild_locations => :environment do
    RetropenBot.default.rebuild_locations
  end

  desc 'Rebuild teams'
  task :rebuild_teams => :environment do
    RetropenBot.default.rebuild_teams
  end

  desc 'Rebuild all'
  task :rebuild_all => :environment do
    RetropenBot.default.rebuild_all
  end

end
