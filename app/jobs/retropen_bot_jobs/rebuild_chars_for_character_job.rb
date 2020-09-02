class RetropenBotJobs::RebuildCharsForCharacterJob < ApplicationJob
  queue_as :chars

  def perform(character, chars_category1_id: nil, chars_category2_id: nil)
    RetropenBot.default.rebuild_chars_for_character(
      character,
      chars_category1_id: chars_category1_id,
      chars_category2_id: chars_category2_id
    )
  end
end
