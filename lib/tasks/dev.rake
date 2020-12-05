require 'smashtheque_api'

namespace :dev do

  desc 'Import characters'
  task :import_characters => :environment do
    raise "not in development" unless Rails.env.development?
    raise "some characters exist" if Character.any?
    ENV['NO_DISCORD'] = '1'
    SmashthequeApi.characters.each do |data|
      data.delete('id')
      Character.new(data).save!
    end
    ENV['NO_DISCORD'] = '0'
  end

  desc 'Import teams'
  task :import_teams => :environment do
    raise "not in development" unless Rails.env.development?
    raise "some teams exist" if Team.any?
    ENV['NO_DISCORD'] = '1'
    SmashthequeApi.teams.each do |data|
      data.delete('id')
      Team.new(data).save!
    end
    ENV['NO_DISCORD'] = '0'
  end

  desc 'Import locations'
  task :import_locations => :environment do
    raise "not in development" unless Rails.env.development?
    raise "some locations exist" if Location.any?
    ENV['NO_DISCORD'] = '1'
    SmashthequeApi.locations.each do |data|
      data.delete('id')
      Location.new(data).save!
    end
    ENV['NO_DISCORD'] = '0'
  end

  desc 'Import discord_guilds'
  task :import_discord_guilds => :environment do
    raise "not in development" unless Rails.env.development?
    raise "some discord_guilds exist" if Team.any?
    ENV['NO_DISCORD'] = '1'
    SmashthequeApi.discord_guilds.each do |data|
      data.delete('id')
      discord_guild = DiscordGuild.new(data)
      discord_guild.discord_guild_relateds = data['relateds'].map do |discord_guild_related|
        related = discord_guild_related['related']
        case discord_guild_related['related_type']
        when 'Character'
          Character.where(name: related['name']).first
        when 'Location'
          Location.where(name: related['name']).first
        when 'Team'
          Team.where(name: related['name']).first
        else
          nil
        end
      end.compact
    end
    discord_guild.save!
    ENV['NO_DISCORD'] = '0'
  end

  desc 'Import all'
  task :reimport_all => :environment do
    raise "not in development" unless Rails.env.development?
    ENV['NO_DISCORD'] = '1'
    Character.destroy_all
    Team.destroy_all
    Location.destroy_all
    DiscordGuild.destroy_all
    Rake::Task['dev:import_characters'].invoke
    Rake::Task['dev:import_teams'].invoke
    Rake::Task['dev:import_locations'].invoke
    Rake::Task['dev:import_discord_guilds'].invoke
    ENV['NO_DISCORD'] = '0'
  end

end
