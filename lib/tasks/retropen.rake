namespace :retropen do

  desc 'Rebuild ABC'
  task :rebuild_abc => :environment do
    RetropenBot.default.rebuild_abc
  end

end
