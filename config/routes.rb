Rails.application.routes.draw do
  devise_for :users
  resources :holdings
  resources :coins
  resources :portfolios
  resources :transactions
  root to: 'portfolios#index'

  get "up" => "rails/health#show", as: :rails_health_check
end
