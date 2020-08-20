# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

# temp
City.destroy_all
Character.destroy_all
Team.destroy_all
Player.destroy_all

# City
uri = "#{ENV['SEED_DATA_SOURCE_URL']}cities.json"
puts "seed #{uri}"
open(uri) do |file|
  cities = JSON.parse(file.read)
  cities.each do |city|
    City.create!(city)
  end
end

# Character
uri = "#{ENV['SEED_DATA_SOURCE_URL']}characters.json"
puts "seed #{uri}"
open(uri) do |file|
  characters = JSON.parse(file.read)
  characters.each do |character|
    Character.create!(character)
  end
end

# Team
uri = "#{ENV['SEED_DATA_SOURCE_URL']}teams.json"
puts "seed #{uri}"
open(uri) do |file|
  teams = JSON.parse(file.read)
  teams.each do |team|
    Team.create!(team)
  end
end

# Player
uri = "#{ENV['SEED_DATA_SOURCE_URL']}players.json"
puts "seed #{uri}"
open(uri) do |file|
  players = JSON.parse(file.read)
  players.each do |player|
    Player.create!(
      name: player['name'],
      city: player['city'].presence && City.find_by!(name: player['city']),
      team: player['team'].presence && Team.find_by!(short_name: player['team']),
      character_ids: player['characters'].map{|c| Character.find_by!(name: c).id}
    )
  end
end
