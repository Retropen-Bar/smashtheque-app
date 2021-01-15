class RevertUserDiscordUserLink < ActiveRecord::Migration[6.0]
  def change
    # create & fill new relation
    add_reference :discord_users, :user
    DiscordUser.find_each do |discord_user|
      discord_user.user = User.where(discord_user_id: discord_user.id)
                              .first_or_create!(
                                name: discord_user.username
                              )
      discord_user.save!
    end

    # add foreign key to prevent corruption
    add_foreign_key :discord_users, :users

    # remove old relation
    remove_column :users, :discord_user_id
  end
end
