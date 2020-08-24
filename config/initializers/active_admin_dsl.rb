require 'active_admin/paper_trail/dsl'

::ActiveAdmin::DSL.send :include, ActiveAdmin::PaperTrail::DSL
