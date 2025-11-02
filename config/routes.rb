Rails.application.routes.draw do
  resources :transactions
  resources :assets, only: [:index, :show], path: 'coins' do
    member do
      post :recalculate_balance
    end
    collection do
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
