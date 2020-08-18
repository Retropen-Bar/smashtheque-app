namespace :retropen do

  desc 'Rebuild ABC'
  task :rebuild_abc => :environment do
    RetropenBot.new.rebuild_abc
  end

end
