class Player < ApplicationRecord

  belongs_to :city, optional: true
  belongs_to :team, optional: true

  has_many :characters_players, dependent: :destroy
  has_many :characters, through: :characters_players

  validates :name, presence: true

  # callbacks

  after_commit :update_discord

  def update_discord
    # on create: previous_changes = {"id"=>[nil, <id>], "name"=>[nil, <name>], ...}
    # on update: previous_changes = {"name"=>["old_name", "new_name"], ...}
    # on delete: destroyed? = true and old attributes are available

    if destroyed?
      # this is a deletion
      RetropenBot.default.rebuild_for_name name
    elsif previous_changes.has_key?('name')
      # this is creation or an update with changes on the name
      old_name = previous_changes['name'].first
      new_name = previous_changes['name'].last
      if old_name&.first != new_name&.first
        RetropenBot.default.rebuild_for_name old_name
      end
      RetropenBot.default.rebuild_for_name new_name
    else
      # this is an update, and the name didn't change
      RetropenBot.default.rebuild_for_name name
    end
  end

  # scopes

  def self.on_abc(letter)
    where("name ILIKE '#{letter}%'")
  end

  def self.on_abc_others
    result = self
    ('a'..'z').each do |letter|
      result = result.where.not("name ILIKE '#{letter}%'")
    end
    result
  end

end
