Rails.application.routes.draw do
  resources :transactions
  resources :assets, only: [:index, :show], path: 'portfolio' do
    member do
      post :recalculate_balance
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
