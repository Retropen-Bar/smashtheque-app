module HasProblems
  extend ActiveSupport::Concern

  included do
    # ---------------------------------------------------------------------------
    # RELATIONS
    # ---------------------------------------------------------------------------

    has_many :problems

    # ---------------------------------------------------------------------------
    # SCOPES
    # ---------------------------------------------------------------------------

    def self.with_problems
      where(id: Problem.select("#{model_name.singular}_id".to_sym))
    end
  end
end
