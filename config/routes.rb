Rails.application.routes.draw do

  # admin

  devise_config = ActiveAdmin::Devise.config
  devise_config[:controllers][:omniauth_callbacks] = 'admin_users/omniauth_callbacks'
  devise_for :admin_users, devise_config

  ActiveAdmin.routes(self)

  # public

  resources :characters, only: :index
  get '/characters/:id' => 'players#character_index', as: :character

  resources :cities, only: :index
  get '/cities/:id' => 'players#city_index', as: :city

  resources :players, only: :index

  resources :teams, only: :index
  get '/teams/:id' => 'players#team_index', as: :team

  root to: 'public#home'

end
