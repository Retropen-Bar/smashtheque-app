require 'active_admin/bracket/dsl'
require 'active_admin/paper_trail/dsl'

::ActiveAdmin::DSL.send :include, ActiveAdmin::Bracket::DSL
::ActiveAdmin::DSL.send :include, ActiveAdmin::PaperTrail::DSL

ActiveAdmin::Devise::SessionsController.class_eval do
  def root_path
    '/'
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
