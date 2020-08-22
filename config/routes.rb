Rails.application.routes.draw do

  # ADMIN

  devise_config = ActiveAdmin::Devise.config
  devise_config[:controllers][:omniauth_callbacks] = 'admin_users/omniauth_callbacks'
  devise_for :admin_users, devise_config

  ActiveAdmin.routes(self)

  # API

  namespace :api do
    namespace :v1 do
      get '/search' => 'search#global'
    end
  end

  # PUBLIC

  resources :characters, only: :index
  get '/characters/:id' => 'players#character_index', as: :character

  resources :cities, only: :index
  get '/cities/:id' => 'players#city_index', as: :city

  resources :players, only: [:index, :show]

  resources :teams, only: :index
  get '/teams/:id' => 'players#team_index', as: :team

  root to: 'public#home'

end
