class Player < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :city, optional: true
  belongs_to :team, optional: true

  has_many :characters_players,
           dependent: :destroy
  has_many :characters,
           through: :characters_players,
           after_remove: :after_remove_character

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :name, presence: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord
  def update_discord
    # on create: previous_changes = {"id"=>[nil, <id>], "name"=>[nil, <name>], ...}
    # on update: previous_changes = {"name"=>["old_name", "new_name"], ...}
    # on delete: destroyed? = true and old attributes are available

    if destroyed?
      # this is a deletion
      RetropenBot.default.rebuild_abc_for_name name
      RetropenBot.default.rebuild_cities_for_city city if city
    else
      # name
      if previous_changes.has_key?('name')
        # this is creation or an update with changes on the name
        old_name = previous_changes['name'].first
        new_name = previous_changes['name'].last
        if RetropenBot.default.name_letter(old_name) != RetropenBot.default.name_letter(new_name)
          RetropenBot.default.rebuild_abc_for_name old_name
        end
        RetropenBot.default.rebuild_abc_for_name new_name

      else
        # this is an update, and the name didn't change
        RetropenBot.default.rebuild_abc_for_name name
      end

      # city
      if previous_changes.has_key?('city_id')
        # this is creation or an update with changes on the city_id
        old_city_id = previous_changes['city_id'].first
        new_city_id = previous_changes['city_id'].last
        RetropenBot.default.rebuild_cities_for_city City.find(old_city_id) if old_city_id
        RetropenBot.default.rebuild_cities_for_city City.find(new_city_id)

      else
        # this is an update, and the city_id didn't change
        RetropenBot.default.rebuild_cities_for_city city
      end
    end

    # this handles both existing and new characters
    RetropenBot.default.rebuild_chars_for_characters characters
  end

  # this is required because removing a has_many relation
  # is not visible inside an after_commit callback
  def after_remove_character(character)
    RetropenBot.default.rebuild_chars_for_character character
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.on_abc(letter)
    where("unaccent(name) ILIKE '#{letter}%'")
  end

  def self.on_abc_others
    result = self
    ('a'..'z').each do |letter|
      result = result.where.not("unaccent(name) ILIKE '#{letter}%'")
    end
    result
  end

end
