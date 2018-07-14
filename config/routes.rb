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

  # https://github.com/mperham/sidekiq/wiki/Monitoring#rails-http-basic-auth-from-routes
  require 'sidekiq/web'
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(username),
        ::Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_USERNAME'))
      ) &
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(password),
          ::Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_PASSWORD'))
        )
    end
  end
  mount Sidekiq::Web => '/sidekiq'
end
