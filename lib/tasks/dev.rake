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

  desc 'Import communities'
  task :import_communities => :environment do
    raise "not in development" unless Rails.env.development?
    raise "some communities exist" if Community.any?
    ENV['NO_DISCORD'] = '1'
    SmashthequeApi.communities.each do |data|
      data.delete('id')
      Community.new(data).save!
    end
    ENV['NO_DISCORD'] = '0'
  end

  desc 'Import players'
  task :import_players => :environment do
    raise "not in development" unless Rails.env.development?
    raise "some players exist" if Player.any?
    ENV['NO_DISCORD'] = '1'
    SmashthequeApi.players.each do |data|
      data.delete('id')
      data['character_ids'] = data['character_names'].map do |character_name|
        Character.find_by!(name: character_name).id
      end
      data.delete('characters')
      data['team_ids'] = data['teams'].map do |team|
        Team.find_by!(name: team['name']).id
      end
      data.delete('teams')
      data.delete('creator')
      data.delete('discord_user')
      data.delete('best_player_reward_condition_id')
      data.delete('best_reward_level1')
      data.delete('best_reward_level2')
      Player.new(data).save!
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
          when 'Community'
            Community.where(name: related_data['name']).first
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

  desc 'Import recurring_tournaments'
  task :import_recurring_tournaments => :environment do
    raise "not in development" unless Rails.env.development?
    raise "some recurring_tournaments exist" if RecurringTournament.any?
    ENV['NO_DISCORD'] = '1'
    SmashthequeApi.recurring_tournaments.each do |data|
      data.delete('id')
      RecurringTournament.new(data).save!
    end
    ENV['NO_DISCORD'] = '0'
  end

  desc 'Import tournament_events'
  task :import_tournament_events => :environment do
    raise "not in development" unless Rails.env.development?
    raise "some tournament_events exist" if TournamentEvent.any?
    ENV['NO_DISCORD'] = '1'
    SmashthequeApi.tournament_events.each do |data|
      data.delete('id')
      data['recurring_tournament_id'] = RecurringTournament.find_by!(
        name: data.delete('recurring_tournament_name')
      )
      TournamentEvent::PLAYER_NAMES.each do |player_name|
        if player_name = data.delete("#{player_name}_name")
          data["#{player_name}_id"] = Player.find_by!(name: player_name)
        end
      end
      RecurringTournament.new(data).save!
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
    Community.destroy_all
    Player.destroy_all
    DiscordGuild.destroy_all
    RecurringTournament.destroy_all
    puts 'import characters'
    Rake::Task['dev:import_characters'].invoke
    puts 'import teams'
    Rake::Task['dev:import_teams'].invoke
    puts 'import communities'
    Rake::Task['dev:import_communities'].invoke
    puts 'import players'
    Rake::Task['dev:import_players'].invoke
    puts 'import discord guilds'
    Rake::Task['dev:import_discord_guilds'].invoke
    puts 'import recurring tournaments'
    Rake::Task['dev:import_recurring_tournaments'].invoke
    puts 'import tournament events'
    Rake::Task['dev:import_tournament_events'].invoke
    ENV['NO_DISCORD'] = '0'
  end

end
