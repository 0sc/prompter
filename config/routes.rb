Rails.application.routes.draw do
  root 'users#new'
  get '/auth/:provider/callback', to: 'users#create'
  get '/auth/:provider/failure', to: 'users#failed'
  get '/users/:psid/account_link', to: 'users#account_link'

  resources :users, only: :new do
    member { get :login }
    collection { get :logout }
  end

  resources :communities, except: %i[new]
  resources :community_member_profiles, only: %i[show edit update] do
    collection { get :curtain }
  end

  mount Facebook::Messenger::Server, at: 'bot'

  unless Rails.env == 'production'
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
