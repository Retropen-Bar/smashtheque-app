namespace :retropen do

  desc 'Rebuild ABC'
  task :rebuild_abc => :environment do
    RetropenBotScheduler.rebuild_abc
  end

  desc 'Rebuild chars'
  task :rebuild_chars => :environment do
    RetropenBotScheduler.rebuild_chars
  end

  desc 'Rebuild teams'
  task :rebuild_teams => :environment do
    RetropenBotScheduler.rebuild_teams
  end

  desc 'Rebuild all'
  task :rebuild_all => :environment do
    RetropenBotScheduler.rebuild_all
  end

end
