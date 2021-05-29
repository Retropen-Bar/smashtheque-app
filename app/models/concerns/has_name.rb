module HasName
  extend ActiveSupport::Concern

  included do
    # ---------------------------------------------------------------------------
    # SCOPES
    # ---------------------------------------------------------------------------

    # NEEDS method self.on_abc_name

    def self.on_abc(letter)
      if letter == '$'
        on_abc_others
      else
        where(
          "unaccent(#{sanitize_sql(on_abc_name)}) ILIKE ?", "#{letter}%"
        )
      end
    end

    def self.on_abc_others
      result = self
      ('a'..'z').each do |letter|
        result = result.where.not(
          "unaccent(#{sanitize_sql(on_abc_name)}) ILIKE ?", "#{letter}%"
        )
      end
      result
    end
  end
end
