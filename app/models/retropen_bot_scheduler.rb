class RetropenBotScheduler

  # ---------------------------------------------------------------------------
  # ABC
  # ---------------------------------------------------------------------------

  def self.rebuild_abc_for_name(name,
                                abc_category_id: nil)
    return false if name.blank?
    RetropenBotJobs::RebuildAbcForLetterJob.perform_later(
      name_letter(name),
      abc_category_id: abc_category_id
    )
  end

  # ---------------------------------------------------------------------------
  # LOCATIONS
  # ---------------------------------------------------------------------------

  def rebuild_locations_for_location(location,
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

  # ---------------------------------------------------------------------------
  # CHARS
  # ---------------------------------------------------------------------------

  def rebuild_chars_for_character(character,
                                  chars_category1_id: nil,
                                  chars_category2_id: nil)
    RetropenBotJobs::RebuildCharsForCharacter.perform_later(
      character,
      chars_category1_id: chars_category1_id,
      chars_category2_id: chars_category2_id
    )
  end

  def rebuild_chars_for_characters(characters,
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

  # ---------------------------------------------------------------------------
  # TEAMS
  # ---------------------------------------------------------------------------

  def rebuild_teams_list(teams_category_id: nil)
    RetropenBotJobs::RebuildTeamsListJob.perform_later(
      teams_category_id: teams_category_id
    )
  end

  def rebuild_teams_lu(teams_category_id: nil)
    RetropenBotJobs::RebuildTeamsLuJob.perform_later(
      teams_category_id: teams_category_id
    )
  end

  def rebuild_teams(teams_category_id: nil)
    _teams_category_id = teams_category_id || RetropenBot.default.teams_category['id']
    rebuild_teams_list teams_category_id: _teams_category_id
    rebuild_teams_lu teams_category_id: _teams_category_id
  end

end
