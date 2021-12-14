class EnrichRecurringTournamentTexts < ActiveRecord::Migration[6.0]
  def change
    RecurringTournament.find_each do |record|
      %i[misc registration].each do |attribute|
        value = record.read_attribute(attribute)
        next if value.blank?

        ActionText::RichText.new(
          name: attribute.to_s,
          body: ActionText::Content.new(value),
          record_type: :RecurringTournament,
          record_id: record.id,
          created_at: record.created_at,
          updated_at: record.updated_at
        ).save!
      end
    end
  end
end
