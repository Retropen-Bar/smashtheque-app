class ChangeEmojis < ActiveRecord::Migration[6.0]
  def change
    Character.all.each do |character|
      character.emoji = character.head_icon_url.gsub(/.*\/(\d+)\.png/, '\1')
      character.save!
    end
    remove_column :characters, :head_icon_url
  end
end
