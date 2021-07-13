module ActiveAdmin
  module Bracket
    module DSL
      def is_bracket
        # -----------------------------------------------------------------------
        # CONFIG
        # -----------------------------------------------------------------------

        actions :index, :show, :new, :create, :destroy

        # -----------------------------------------------------------------------
        # SCOPES
        # -----------------------------------------------------------------------

        scope :all, default: true

        scope :not_ignored, group: :ignored
        scope :ignored, group: :ignored

        scope :with_any_tournament_event, group: :tournament_event
        scope :without_any_tournament_event, group: :tournament_event

        # -----------------------------------------------------------------------
        # FORM
        # -----------------------------------------------------------------------

        before_create(&:fetch_provider_data)

        # -----------------------------------------------------------------------
        # BATCH ACTIONS
        # -----------------------------------------------------------------------

        batch_action :ignore do |ids|
          batch_action_collection.where(id: ids).each do |event|
            event.is_ignored = true
            event.save!
          end
          redirect_to request.referer, notice: 'Modifications effectuées'
        end

        batch_action :stop_ignoring do |ids|
          batch_action_collection.where(id: ids).each do |event|
            event.is_ignored = false
            event.save!
          end
          redirect_to request.referer, notice: 'Modifications effectuées'
        end

        batch_action :create_tournament_event, form: -> {
          {
            I18n.t('activerecord.models.recurring_tournament') => (
              [['Aucune', '']] + RecurringTournament.order('LOWER(name)').pluck(:name, :id)
            )
          }
        } do |ids, inputs|
          if batch_action_collection.where(id: ids).with_tournament_event.any?
            flash[:error] = 'Certains tournois sont déjà reliés à une édition'
            redirect_to request.referer
          elsif batch_action_collection.where(id: ids).ignored.any?
            flash[:error] = 'Certains tournois sont ignorés'
            redirect_to request.referer
          else
            recurring_tournament_id = inputs[I18n.t('activerecord.models.recurring_tournament')]
            unless recurring_tournament_id.blank?
              recurring_tournament = RecurringTournament.find(recurring_tournament_id)
            end
            batch_action_collection.where(id: ids).each do |bracket|
              bracket.fetch_provider_data
              bracket.save!
              tournament_event = TournamentEvent.new(
                recurring_tournament: recurring_tournament,
                bracket: bracket
              )
              tournament_event.use_bracket(true)
              tournament_event.save!
            end
            redirect_to request.referer, notice: 'Éditions 1v1 créées'
          end
        end

        batch_action :create_duo_tournament_event, form: -> {
          {
            I18n.t('activerecord.models.recurring_tournament') => (
              [['Aucune', '']] + RecurringTournament.order('LOWER(name)').pluck(:name, :id)
            )
          }
        } do |ids, inputs|
          if batch_action_collection.where(id: ids).with_duo_tournament_event.any?
            flash[:error] = 'Certains tournois sont déjà reliés à une édition'
            redirect_to request.referer
          elsif batch_action_collection.where(id: ids).ignored.any?
            flash[:error] = 'Certains tournois sont ignorés'
            redirect_to request.referer
          else
            recurring_tournament_id = inputs[I18n.t('activerecord.models.recurring_tournament')]
            unless recurring_tournament_id.blank?
              recurring_tournament = RecurringTournament.find(recurring_tournament_id)
            end
            batch_action_collection.where(id: ids).each do |bracket|
              bracket.fetch_provider_data
              bracket.save!
              duo_tournament_event = DuoTournamentEvent.new(
                recurring_tournament: recurring_tournament,
                bracket: bracket
              )
              duo_tournament_event.use_bracket(true)
              duo_tournament_event.save!
            end
            redirect_to request.referer, notice: 'Éditions 2v2 créées'
          end
        end

        # -----------------------------------------------------------------------
        # MEMBER ACTIONS
        # -----------------------------------------------------------------------

        member_action :ignore do
          resource.is_ignored = true
          if resource.save
            redirect_to request.referer, notice: 'Modification effectuée'
          else
            flash[:error] = 'Modification impossible'
            redirect_to request.referer
          end
        end

        member_action :stop_ignoring do
          resource.is_ignored = false
          if resource.save
            redirect_to request.referer, notice: 'Modification effectuée'
          else
            flash[:error] = 'Modification impossible'
            redirect_to request.referer
          end
        end

        member_action :fetch_provider_data do
          resource.fetch_provider_data
          if resource.save
            redirect_to [:admin, resource], notice: 'Import réussi'
          else
            flash[:error] = 'Import échoué'
            redirect_to request.referer
          end
        end

        # -----------------------------------------------------------------------
        # ACTION ITEMS
        # -----------------------------------------------------------------------

        action_item :ignore,
                    only: :show,
                    if: proc { !resource.is_ignored? } do
          link_to 'Ignorer', [:ignore, :admin, resource]
        end

        action_item :stop_ignoring,
                    only: :show,
                    if: proc { resource.is_ignored? } do
          link_to 'Ne plus ignorer', [:stop_ignoring, :admin, resource]
        end

        action_item :fetch_provider_data,
                    only: :show do
          link_to 'Importer les données',
                  [:fetch_provider_data, :admin, resource],
                  class: 'orange'
        end

        action_item :create_tournament_event,
                    only: :show,
                    if: proc {
                      resource.tournament_event.nil? && resource.duo_tournament_event.nil? && !resource.is_ignored?
                    } do
          dropdown_menu "Créer l'édition", button: { class: 'blue' } do
            item 'Édition 1v1', resource.create_tournament_event_admin_path
            item 'Édition 2v2', resource.create_duo_tournament_event_admin_path
          end
        end
      end
    end
  end
end
