class LinkPlayersToUsers < ActiveRecord::Migration[6.0]
  def change
    # creator
    add_column :players, :creator_user_id, :integer
    add_index :players, :creator_user_id
    add_foreign_key :players, :users, column: :creator_user_id
    Player.find_each do |player|
      next if player.creator_id.nil?
      player.creator_user_id = DiscordUser.find(player.creator_id)
                                          .return_or_create_user!
                                          .id
      player.save!
    end
    remove_column :players, :creator_id

    # user
    add_column :players, :user_id, :integer
    add_index :players, :user_id
    add_foreign_key :players, :users, column: :user_id
    Player.find_each do |player|
      next if player.discord_user_id.nil?
      player.user_id = DiscordUser.find(player.discord_user_id)
                                  .return_or_create_user!
                                  .id
      player.save!
    end
    remove_column :players, :discord_user_id
  end
end
