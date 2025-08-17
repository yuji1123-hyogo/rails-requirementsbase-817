Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "hello#index"
  
  namespace :api do
    resources :books, only: [:create, :index, :show, :update, :destroy]
  end

end
