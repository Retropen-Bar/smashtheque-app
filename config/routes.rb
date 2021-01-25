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
      resources :duos, only: [:index, :show, :create, :update]
      resources :locations, only: [:index, :create]
      resources :recurring_tournaments, only: [:index, :show]
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
      get :locations
      get :others
    end
  end

  resources :duos, only: [:index, :show] do
    collection do
      get 'ranking/online' => 'duos#ranking_online', as: :online_ranking
    end
  end

  resources :locations, only: :index
  get 'locations/:id' => 'players#location_index', as: :location

  resources :players, only: [:index, :show] do
    collection do
      get 'ranking/online' => 'players#ranking_online', as: :online_ranking
    end
  end

  resources :teams, only: :index
  get 'teams/:id' => 'players#team_index', as: :team

  resources :recurring_tournaments, only: [:index, :show] do
    member do
      get :modal
    end
  end
  resources :tournament_events, only: [:index, :show]
  resources :duo_tournament_events, only: [:index, :show]
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

  get 'credits' => 'pages#credits', as: :credits
  get 'mentions-legales' => 'pages#legal', as: :legal

  root to: 'pages#home'

end
