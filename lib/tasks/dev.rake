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
      Locations::City.new(data).save!
    end
    ENV['NO_DISCORD'] = '0'
  end

  desc 'Import discord_guilds'
  task :import_discord_guilds => :environment do
    raise "not in development" unless Rails.env.development?
    raise "some discord_guilds exist" if DiscordGuild.any?
    ENV['NO_DISCORD'] = '1'
    SmashthequeApi.discord_guilds.each do |data|
      data.delete('id')
      relateds = data.delete('relateds')
      discord_guild = DiscordGuild.new(data)
      discord_guild.discord_guild_relateds = relateds.map do |discord_guild_related|
        related_data = discord_guild_related['related']
        related = case discord_guild_related['related_type']
          when 'Character'
            Character.where(name: related_data['name']).first
          when 'Player'
            Player.where(name: related_data['name']).first
          when 'Location'
            Location.where(name: related_data['name']).first
          when 'Team'
            Team.where(name: related_data['name']).first
          else
            nil
          end
        related && discord_guild.discord_guild_relateds.build(related: related)
      end.compact
      discord_guild.save!
    end
    ENV['NO_DISCORD'] = '0'
  end

  desc 'Import all'
  task :reimport_all => :environment do
    raise "not in development" unless Rails.env.development?
    ENV['NO_DISCORD'] = '1'
    puts 'delete data'
    Character.destroy_all
    Team.destroy_all
    Location.destroy_all
    DiscordGuild.destroy_all
    puts 'import characters'
    Rake::Task['dev:import_characters'].invoke
    puts 'import teams'
    Rake::Task['dev:import_teams'].invoke
    puts 'import locations'
    Rake::Task['dev:import_locations'].invoke
    puts 'import discord guilds'
    Rake::Task['dev:import_discord_guilds'].invoke
    ENV['NO_DISCORD'] = '0'
  end

end
