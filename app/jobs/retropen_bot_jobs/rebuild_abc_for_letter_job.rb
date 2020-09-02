class RetropenBotJobs::RebuildAbcForLetterJob < ApplicationJob
  queue_as :abc

  def perform(letter, abc_category_id: nil)
    RetropenBot.default.rebuild_abc_for_letter(
      letter,
      abc_category_id
    )
  end
end
