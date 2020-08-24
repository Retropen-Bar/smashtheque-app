namespace :discord do

  desc 'Fetch unknown accounts'
  task :fetch_unknown => :environment do
    DiscordUser.fetch_unknown
  end

end
