Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  
  authenticated :user do
    root to: 'goals#index', as: :authenticated_root
  end
  root to: 'visitors#index'

  resources :goals, only: [:index, :create, :show]
  resources :activities, only: [:index, :create, :new]
  resources :users, only: [:edit, :update]
end
