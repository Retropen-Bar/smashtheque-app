class RetropenBotScheduler

  def self.rebuild_all
    rebuild_abc
    rebuild_chars
    rebuild_locations
    rebuild_teams
  end

  # ---------------------------------------------------------------------------
  # ABC
  # ---------------------------------------------------------------------------

  def self.rebuild_abc_for_name(name,
                                abc_category_id: nil)
    return false if name.blank?
    RetropenBotJobs::RebuildAbcForLetterJob.perform_later(
      RetropenBot.name_letter(name),
      abc_category_id: abc_category_id
    )
  end

  # def self.rebuild_abc_for_letters(letters, _abc_category_id = nil)
  #   abc_category_id = _abc_category_id || abc_category['id']
  #   need_rebuild_abc_others = false
  #   letters.compact.uniq.each do |letter|
  #     if ('a'..'z').include?(letter)
  #       rebuild_abc_letter letter, abc_category_id
  #     else
  #       need_rebuild_abc_others = true
  #     end
  #   end
  #   rebuild_abc_others(abc_category_id) if need_rebuild_abc_others
  # end

  # def self.rebuild_abc_for_players(players,
  #                                  abc_category_id: nil)
  #   _abc_category_id = abc_category_id || RetropenBot.default.abc_category['id']
  #   letters = players.map do |player|
  #     RetropenBot.name_letter player&.name
  #   end
  #   rebuild_abc_for_letters letters, abc_category_id
  # end

  def self.rebuild_abc(abc_category_id: nil)
    _abc_category_id = abc_category_id || RetropenBot.default.abc_category['id']
    ('a'..'z').each do |letter|
      RetropenBotJobs::RebuildAbcForLetterJob.perform_later(
        letter,
        abc_category_id: _abc_category_id
      )
    end
    RetropenBotJobs::RebuildAbcForLetterJob.perform_later(
      '$',
      abc_category_id: _abc_category_id
    )
  end

  # ---------------------------------------------------------------------------
  # LOCATIONS
  # ---------------------------------------------------------------------------

  def self.rebuild_locations_for_location(location,
                                          cities_category_id: nil,
                                          countries_category_id: nil)
    return false if location.nil?
    return false unless location.is_main?
    RetropenBotJobs::RebuildLocationsForLocationJob.perform_later(
      location,
      cities_category_id: cities_category_id,
      countries_category_id: countries_category_id
    )
  end

  def self.rebuild_locations_for_locations(locations,
                                           cities_category_id: nil,
                                           countries_category_id: nil)
    _cities_category_id = cities_category_id || RetropenBot.default.cities_category['id']
    _countries_category_id = countries_category_id || RetropenBot.default.countries_category['id']
    locations.to_a.compact.uniq.each do |location|
      rebuild_locations_for_location location,
                                     cities_category_id: _cities_category_id,
                                     countries_category_id: _countries_category_id
    end
  end

  def self.rebuild_locations(cities_category_id: nil,
                             countries_category_id: nil)
    rebuild_locations_for_locations Location.order(:name),
                                    cities_category_id: cities_category_id,
                                    countries_category_id: countries_category_id
  end

  # ---------------------------------------------------------------------------
  # CHARS
  # ---------------------------------------------------------------------------

  def self.rebuild_chars_for_character(character,
                                       chars_category1_id: nil,
                                       chars_category2_id: nil)
    RetropenBotJobs::RebuildCharsForCharacterJob.perform_later(
      character,
      chars_category1_id: chars_category1_id,
      chars_category2_id: chars_category2_id
    )
  end

  def self.rebuild_chars_for_characters(characters,
                                        chars_category1_id: nil,
                                        chars_category2_id: nil)
    _chars_category1_id = chars_category1_id || RetropenBot.default.chars_category1['id']
    _chars_category2_id = chars_category2_id || RetropenBot.default.chars_category2['id']
    characters.compact.uniq.each do |character|
      rebuild_chars_for_character(
        character,
        chars_category1_id: _chars_category1_id,
        chars_category2_id: _chars_category2_id
      )
    end
  end

  def self.rebuild_chars(chars_category1_id: nil,
                         chars_category2_id: nil)
    rebuild_chars_for_characters Character.all,
                                 chars_category1_id: chars_category1_id,
                                 chars_category2_id: chars_category2_id
  end

  # ---------------------------------------------------------------------------
  # TEAMS
  # ---------------------------------------------------------------------------

  def self.rebuild_teams_list(teams_category_id: nil)
    RetropenBotJobs::RebuildTeamsListJob.perform_later(
      teams_category_id: teams_category_id
    )
  end

  def self.rebuild_teams_lu(teams_category_id: nil)
    RetropenBotJobs::RebuildTeamsLuJob.perform_later(
      teams_category_id: teams_category_id
    )
  end

  def self.rebuild_teams(teams_category_id: nil)
    _teams_category_id = teams_category_id || RetropenBot.default.teams_category['id']
    rebuild_teams_list teams_category_id: _teams_category_id
    rebuild_teams_lu teams_category_id: _teams_category_id
  end

end
