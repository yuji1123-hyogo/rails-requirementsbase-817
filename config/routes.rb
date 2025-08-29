Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "hello#index"
  
  namespace :api do
    resources :books, only: [:create, :index, :show, :update, :destroy] do
      resources :comments, only: [:create, :index, :update, :destroy], shallow: true
      resources :likes, only: [:create]
    end
    get 'my_likes', to: 'likes#index'
    delete 'likes/:book_id', to: 'likes#destroy'
    post "register", to: "users#create"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"
    get 'profile', to: 'users#show'
    put 'profile', to: 'users#update'
  end

end
