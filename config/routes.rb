Rails.application.routes.draw do
  resources :holdings
  resources :coins
  resources :portfolios
  resources :transactions
  # resources :assets, only: [:index, :show], path: 'coins', param: :name do
  #   member do
  #     post :recalculate_balance
  #   end
  #   collection do
  #   end
  # end

  get "up" => "rails/health#show", as: :rails_health_check
end
