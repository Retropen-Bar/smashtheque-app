require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do

  # ADMIN

  devise_config = ActiveAdmin::Devise.config
  devise_config[:controllers][:omniauth_callbacks] = 'users/omniauth_callbacks'
  devise_for :users, devise_config

  ActiveAdmin.routes(self)

  # SIDEKIQ

  mount Sidekiq::Web => '/sidekiq'

  # API

  namespace :api do
    namespace :v1 do
      resources :characters, only: :index
      resources :discord_guilds, only: :index
      resources :discord_users, param: :discord_id, only: :show do
        member do
          get :refetch
        end
      end
      resources :duo_tournament_events, only: [:index, :show, :create]
      resources :duos, only: [:index, :show, :create, :update]
      resources :communities, only: [:index]
      resources :recurring_tournaments, only: [:index, :show] do
        resources :players,
                  only: [:update],
                  controller: :players_recurring_tournaments,
                  param: :player_id
        put 'discord_users/:discord_id' => 'players_recurring_tournaments#update_by_discord_id'
      end
      resources :players, only: [:index, :show, :create, :update]
      resources :teams, only: [:index, :show, :update]
      resources :tournament_events, only: [:index, :show, :create]
      get '/search' => 'search#global'
    end
  end

  # API DOC

  mount Rswag::Ui::Engine => '/api/docs'
  mount Rswag::Api::Engine => '/api/docs'

  # PUBLIC

  resources :characters, only: :index
  get 'characters/:id' => 'players#character_index', as: :character

  resources :discord_guilds, only: [:index] do
    collection do
      get :characters
      get :players
      get :teams
      get :communities
      get :others
    end
  end

  resources :discord_users, only: [] do
    member do
      get :refetch
    end
  end

  resources :duos, only: [:index, :show] do
    collection do
      get :autocomplete
      get :ranking
    end
  end

  resources :communities, only: :index
  get 'communities/:id' => 'players#community_index', as: :community

  resources :players, only: [:index, :show] do
    resources :smashgg_users, only: [:new, :create]
    collection do
      get :autocomplete
      get :ranking
    end
  end

  resources :teams, only: [:index, :edit, :update]
  get 'teams/:id' => 'players#team_index'

  resources :recurring_tournaments, only: %i[index show edit update] do
    resources :tournament_events, only: %i[new create]
    resources :duo_tournament_events, only: %i[new create]
    collection do
      get 'contacts' => 'players#recurring_tournament_contacts_index'
    end
    member do
      get :modal
    end
  end
  resources :tournament_events, only: [:index, :show, :edit, :update]
  resources :duo_tournament_events, only: [:index, :show, :edit, :update]
  get 'planning/online' => 'pages#planning_online', as: :planning

  resources :twitch_channels, only: [:index]
  resources :you_tube_channels, only: [:index]
  resources :caster_users, only: [:index], path: :casters
  resources :coach_users, only: [:index], path: :coaches
  resources :graphic_designer_users, only: [:index], path: :graphic_designers

  resources :users, only: %i(show edit update) do
    member do
      get :create_player
    end
  end

  resources :pages, param: :slug, only: :show

  get 'bot' => 'redirections#bot'

  unless Rails.application.config.consider_all_requests_local
    get '*path', to: 'application#render_404', via: :all
  end

  root to: 'pages#home'

end
