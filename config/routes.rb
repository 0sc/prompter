Rails.application.routes.draw do
  root 'users#new'
  get '/auth/:provider/callback', to: 'users#create'
end
