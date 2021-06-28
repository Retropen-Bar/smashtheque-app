module ActiveAdmin
  module BaseDecorator
    def arbre(&block)
      Arbre::Context.new({}, self, &block).to_s
    end

    def admin_link(options = {})
      with_icon = options.delete(:with_icon)

      txt = options.delete(:label) || name
      txt = fas_icon_tag(icon_class) + '&nbsp;'.html_safe + txt if with_icon
      options[:class] = [
        options[:class],
        model.respond_to?(:discarded?) && (model.discarded? ? 'discarded' : 'kept') || nil
      ].reject(&:blank?).join(' ')
      h.link_to txt, (options[:url] || [:admin, model]), options
    end
  end
end
