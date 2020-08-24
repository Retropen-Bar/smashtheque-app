module ActiveAdmin
  module PaperTrail
    module DSL

      # Call this inside your resource definition to add the needed member actions
      # for your sortable resource.
      #
      # Example:
      #
      # #app/admin/players.rb
      #
      # ActiveAdmin.register Player do
      #   # Sort players by position
      #   config.sort_order = 'position'
      #
      #   # Add member actions for versioning.
      #   has_paper_trail
      # end
      def has_paper_trail

        # add versions timeline sidebar on show page
        sidebar I18n.t('active_admin.paper_trail.sidebar.title'),
                partial: 'layouts/active_admin/paper_trail/version',
                only: :show

        controller do
          # build a @versions variable for the sidebar
          # also, replace resource with an old version when clicked inside the sidebar
          def find_resource
            resource = super

            # number of available versions
            @versions_count = resource.versions.count

            # use ?version=2 to see version 2 of the resource
            if params[:version]
              @version_number = params[:version].to_i
              @version = resource.versions[@version_number]
              @version_date = @version.previous.created_at
              version_author = @version.paper_trail_originator
              resource = @version.reify
            else
              @version_number = @versions_count
              @version_date = resource.updated_at
              version_author = resource.paper_trail.originator
            end

            # try to find author
            if version_author
              version_author_id, version_author_name = version_author.split(':')
              @version_author = AdminUser.where(id: version_author_id).first || version_author_name
            else
              @version_author = '?'
            end

            # return resource
            resource
          end
        end

        member_action :history do
          find_resource
          @versions = resource.versions.reorder(id: :desc)
          render 'layouts/active_admin/paper_trail/history'
        end

        action_item :show, only: :history do
          link_to I18n.t('active_admin.paper_trail.history.show_link'), [:admin, resource]
        end

      end

    end
  end
end
