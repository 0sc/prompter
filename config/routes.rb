Rails.application.routes.draw do
  root 'users#new'
  get '/auth/:provider/callback', to: 'users#create'
  get '/auth/:provider/failure', to: 'users#create'

  resources :communities
end
