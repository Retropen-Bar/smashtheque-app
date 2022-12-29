class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def admin_decorate(options = {})
    admin_decorator_class.decorate(self, options)
  end

  def admin_decorator_class
    self.class.admin_decorator_class
  end

  def self.admin_decorate
    admin_decorator_class.decorate_collection(all)
  end

  def self.admin_decorator_class(called_on = self)
    prefix = respond_to?(:model_name) ? model_name : name
    decorator_name = "ActiveAdmin::#{prefix}Decorator"
    decorator_name_constant = decorator_name.safe_constantize
    return decorator_name_constant unless decorator_name_constant.nil?

    if superclass.respond_to?(:admin_decorator_class)
      superclass.admin_decorator_class(called_on)
    else
      raise Draper::UninferrableDecoratorError.new(called_on)
    end
  end
end
