class CleanRelations < ActiveRecord::Migration[6.0]
  def change
    remove_column :discord_guilds, :old_related_type
    remove_column :discord_guilds, :old_related_id

    DiscordGuildRelated.where(related_type: nil).destroy_all

    change_column :discord_guild_relateds, :related_type, :string, null: false

    DiscordGuildRelated.where(related_id: nil).destroy_all

    {

      discord_guild_relateds: %i(discord_guild_id related_id),
      players: %i(creator_user_id),
      recurring_tournament_contacts: %i(recurring_tournament_id user_id),
      reward_conditions: %i(reward_id),
      team_admins: %i(user_id),
      tournament_events: %i(recurring_tournament_id)

    }.each_pair do |table_name, column_names|
      column_names.each do |column_name|
        change_column table_name, column_name, :integer, null: false
      end
    end

    {

      characters_players: %i(characters players),
      discord_guild_admins: %i(discord_guilds discord_users),
      discord_guild_relateds: %i(discord_guilds),
      locations_players: %i(locations players),
      players_teams: %i(players teams),
      recurring_tournament_contacts: %i(recurring_tournaments),
      recurring_tournaments: %i(discord_guilds),
      reward_conditions: %i(rewards),
      team_admins: %i(teams)

    }.each_pair do |table_name, foreign_table_names|
      foreign_table_names.each do |foreign_table_name|
        add_foreign_key table_name, foreign_table_name
      end
    end

  end
end
