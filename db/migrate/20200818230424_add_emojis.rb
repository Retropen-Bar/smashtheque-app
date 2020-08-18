class AddEmojis < ActiveRecord::Migration[6.0]
  def change
    add_column :characters, :emoji, :string
    add_column :characters, :head_icon_url, :string
  end
end
