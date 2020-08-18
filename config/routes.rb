Rails.application.routes.draw do

  devise_config = ActiveAdmin::Devise.config
  devise_config[:controllers][:omniauth_callbacks] = 'admin_users/omniauth_callbacks'
  devise_for :admin_users, devise_config

  ActiveAdmin.routes(self)

  resources :characters, only: [:index, :show]
  resources :cities, only: [:index, :show]
  resources :players, only: :index
  resources :teams, only: [:index, :show]

  root to: 'players#index'

end
