class CreateDiscordGuildRelateds < ActiveRecord::Migration[6.0]
  def change
    create_table :discord_guild_relateds do |t|
      t.belongs_to :discord_guild
      t.belongs_to :related, polymorphic: true
      t.timestamps
    end

    add_index :discord_guild_relateds,
              [
                :discord_guild_id,
                :related_type,
                :related_id
              ],
              unique: true,
              name: 'index_dgr_on_all'

    DiscordGuild.all.each do |discord_guild|
      if discord_guild.related_id
        DiscordGuildRelated.create!(
          discord_guild_id: discord_guild.id,
          related_type: discord_guild.related_type,
          related_id: discord_guild.related_id
        )
      end
    end

    rename_column :discord_guilds, :related_type, :old_related_type
    rename_column :discord_guilds, :related_id, :old_related_id
  end
end
