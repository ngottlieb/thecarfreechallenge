Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'registrations' }
  
  root to: 'visitors#index'
  
  get '/dashboard', to: 'home#dashboard', as: :dashboard

  resources :goals, except: [:index]
  resources :activities, except: [:show]
  resources :users, only: [:edit, :update]
  resources :milestones, except: [:show]

  get '/help', to: 'home#help', as: :help
  get '/site-wide-stats', to: 'home#site_wide_stats', as: :site_wide_stats

  get '/users/:id/unsubscribe', to: 'users#unsubscribe', as: :unsubscribe

  get '/users/:id/milestones/:milestone_id', to: 'users#share_milestone', as: :share_milestone
  get '/users/:id/share/:achievement', to: 'users#share_achievement', as: :share_achievement

  get '/activities/trigger_import', to: 'activities#trigger_import', as: 'trigger_import'
end
