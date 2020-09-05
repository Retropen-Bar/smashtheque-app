module ActiveAdmin::BaseDecorator

  def arbre(&block)
    Arbre::Context.new({}, self, &block).to_s
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
    ].reject(&:blank?).join(' ')
    h.link_to txt, [:admin, model], options
  end

end
