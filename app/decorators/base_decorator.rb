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

  def admin_link(options = {})
    with_icon = options.delete(:with_icon)

    txt = options.delete(:label) || name
    if with_icon
      txt = h.content_tag(:i, '', class: "fas fa-#{icon_class}") + "&nbsp;".html_safe + txt
    end
    options[:class] = [
      options[:class],
      model.respond_to?(:discarded?) && (model.discarded? ? 'discarded' : 'kept') || nil
    ].compact.join(' ')
    h.link_to txt, [:admin, model], options
  end

end
