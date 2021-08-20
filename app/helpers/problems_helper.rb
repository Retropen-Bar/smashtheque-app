module ProblemsHelper
  def problems_count(val)
    pluralize(val, 'problème signalé', plural: 'problèmes signalés')
  end
end
