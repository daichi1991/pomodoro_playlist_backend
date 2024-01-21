Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      resources :users do
        get :login, on: :collection
        get :get_tokens, on: :collection
        post :refresh_token, on: :collection
      end
      resources :playlists do
        get :current_user_playlists, on: :collection
        get :get_playlist, on: :collection
      end
      resources :pomodoros, only: [:index, :create, :show, :update, :destroy]
    end
  end
  resources :healthcheck, only: [:index]
end
