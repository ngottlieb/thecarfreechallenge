Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  
  authenticated :user do
    root to: 'home#dashboard', as: :authenticated_root
  end
  root to: 'visitors#index'

  resources :goals, except: [:index]
  resources :activities, except: [:show]
  resources :users, only: [:edit, :update]

  get '/activities/trigger_import', to: 'activities#trigger_import', as: 'trigger_import'
end
