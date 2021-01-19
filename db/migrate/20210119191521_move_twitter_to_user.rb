class MoveTwitterToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :twitter_username, :string
    Player.where.not(twitter_username: [nil, '']).each do |player|
      next if player.user_id.nil?
      User.where(
        id: player.user_id
      ).update_all(
        twitter_username: player['twitter_username']
      )
    end
    remove_column :players, :twitter_username
  end
end
