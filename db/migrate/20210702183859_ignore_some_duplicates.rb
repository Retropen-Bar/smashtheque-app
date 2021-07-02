class IgnoreSomeDuplicates < ActiveRecord::Migration[6.0]
  def change
    %i[tournament_events duo_tournament_events].each do |t|
      add_column t, :not_duplicates, :text, array: true, default: []
    end
  end
end
