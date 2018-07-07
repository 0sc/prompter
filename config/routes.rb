Rails.application.routes.draw do
  root 'users#new'
  get '/auth/:provider/callback', to: 'users#create'
  get '/auth/:provider/failure', to: 'users#failed'
  get '/users/:psid/account_link', to: 'users#account_link'

  resources :communities, except: %i[new]
  resources :community_member_profiles, only: %i[show edit update] do
    collection do
      get :curtain
    end
  end

  mount Facebook::Messenger::Server, at: 'bot'
end
