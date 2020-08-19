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
  task :rebuild_cities => :environment do
    RetropenBot.default.rebuild_cities
  end

  desc 'Rebuild teams'
  task :rebuild_teams => :environment do
    RetropenBot.default.rebuild_teams
  end

end
