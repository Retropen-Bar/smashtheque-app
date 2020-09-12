module ActiveAdmin::DiscordUsersHelper

  def discord_user_administrated_discord_guilds_select_collection
    DiscordGuild.known.order(:name).decorate
  end

  def discord_user_administrated_teams_select_collection
    Team.order(:name).decorate
  end

  def discord_user_input(form, name = :discord_user, options = {})
    form.input  name,
                {
                  as: :select,
                  collection: [
                    [
                      form.object.discord_user&.username,
                      form.object.discord_user&.id
                    ]
                  ],
                  input_html: {
                    data: {
                      select2: {
                        minimumInputLength: 3,
                        ajax: {
                          delay: 250,
                          url: autocomplete_admin_discord_users_path,
                          dataType: 'json'
                        }
                      }
                    }
                  }
                }.deep_merge(options)
  end

  def discord_users_input(form, name = :discord_users, options = {})
    form.input  name,
                {
                  as: :select,
                  collection: form.object.send(name).map do |discord_user|
                    [
                      discord_user.username,
                      discord_user.id
                    ]
                  end,
                  input_html: {
                    multiple: true,
                    data: {
                      select2: {
                        minimumInputLength: 3,
                        ajax: {
                          delay: 250,
                          url: autocomplete_admin_discord_users_path,
                          dataType: 'json'
                        }
                      }
                    }
                  }
                }.deep_merge(options)
  end

end
