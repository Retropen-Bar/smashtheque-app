module ActiveAdmin::UsersHelper

  def user_admin_level_select_collection
    Ability::ADMIN_LEVELS.map do |v|
      [
        User.human_attribute_name("admin_level.#{v}"),
        v
      ]
    end
  end

  def user_administrated_teams_select_collection
    Team.order(:name).decorate
  end

  def user_administrated_recurring_tournaments_select_collection
    RecurringTournament.order(:name).decorate
  end

  def user_input(form, name = :user, options = {})
    form.input  name,
                {
                  as: :select,
                  collection: [
                    [
                      form.object.send(name)&.name,
                      form.object.send(name)&.id
                    ]
                  ],
                  input_html: {
                    data: {
                      select2: {
                        minimumInputLength: 2,
                        ajax: {
                          delay: 250,
                          url: autocomplete_admin_users_path,
                          dataType: 'json'
                        },
                        placeholder: "Nom de l'utilisateur",
                        allowClear: true
                      }
                    }
                  }
                }.deep_merge(options)
  end

  def users_input(form, name = :users, options = {})
    form.input  name,
                {
                  as: :select,
                  collection: form.object.send(name).map do |user|
                    [
                      user.name,
                      user.id
                    ]
                  end,
                  input_html: {
                    multiple: true,
                    data: {
                      select2: {
                        minimumInputLength: 2,
                        ajax: {
                          delay: 250,
                          url: autocomplete_admin_users_path,
                          dataType: 'json'
                        }
                      }
                    }
                  }
                }.deep_merge(options)
  end

end
