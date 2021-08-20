class ProblemDecorator < BaseDecorator
  def player_link(options = {})
    player&.decorate&.link(options)
  end

  def duo_link(options = {})
    duo&.decorate&.link(options)
  end

  def recurring_tournament_link(options = {})
    recurring_tournament&.decorate&.link(options)
  end

  def reporting_user_link(options = {})
    reporting_user&.decorate&.link(options)
  end

  def concerned_name
    concerned&.name
  end

  def nature
    return nil if model.nature.blank?

    model.class.human_attribute_name("nature.#{model.nature}")
  end
end
