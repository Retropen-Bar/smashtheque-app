class BaseDecorator < Draper::Decorator

  delegate_all
  include Rails.application.routes.url_helpers

  def arbre(&block)
    Arbre::Context.new({}, self, &block).to_s
  end

  def created_at_date
    h.l model.created_at.to_date, format: :default
  end

  def updated_at_date
    h.l model.updated_at.to_date, format: :default
  end

end