require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do

  # ADMIN

  devise_config = ActiveAdmin::Devise.config
  devise_config[:controllers][:omniauth_callbacks] = 'admin_users/omniauth_callbacks'
  devise_for :admin_users, devise_config

  ActiveAdmin.routes(self)

  # SIDEKIQ

  mount Sidekiq::Web => '/sidekiq'

  # API

  namespace :api do
    namespace :v1 do
      resources :characters, only: :index
      resources :discord_guilds, only: :index
      get '/discord_users/:discord_id', to: 'discord_users#show'
      resources :discord_users, only: :show
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
  get 'planning/online' => 'public#planning_online', as: :planning

  get 'credits' => 'public#credits', as: :credits

  root to: 'public#home'

end
