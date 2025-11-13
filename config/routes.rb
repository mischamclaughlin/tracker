Rails.application.routes.draw do
  devise_for :users

  resources :holdings
  resources :coins
  resources :portfolios
  resources :transactions

  root to: "portfolios#index"

  get "quick_add", to: "quick_add#new", as: :quick_add
  get "up" => "rails/health#show", as: :rails_health_check
end
