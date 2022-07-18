Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  
  authenticated :user do
    root to: 'home#dashboard', as: :authenticated_root
  end
  root to: 'visitors#index'

  resources :goals, except: [:index]
  resources :activities, except: [:show]
  resources :users, only: [:edit, :update]
  resources :milestones, except: [:show]

  get '/help', to: 'home#help', as: :help
  get '/site-wide-stats', to: 'home#site_wide_stats', as: :site_wide_stats

  get '/users/:id/milestones/:milestone_id', to: 'users#share_milestone', as: :share_milestone

  get '/activities/trigger_import', to: 'activities#trigger_import', as: 'trigger_import'
end
