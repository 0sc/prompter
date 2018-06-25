require 'rails_helper'
require 'support/omniauth'

module FakeRouter
  class Route < ::Rails::Engine
    # isolate_namespace FakeRouter
  end

  Route.routes.draw do
    resources :users, only: :create
    resources :communities
  end
end

RSpec.describe UsersController, type: :controller do
  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    before do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
    end

    routes { FakeRouter::Route.routes }

    describe 'successful create' do
      context 'user already exists' do
        let!(:user) { create(:user, fbid: SAMPLE_AUTH_HASH[:uid], email: 'sc') }

        it 'does not duplicate user record' do
          expect { post :create }.not_to(change { User.count })
        end

        it 'updates the user attributes' do
          post :create
          user.reload
          expect(user.email).to eq SAMPLE_AUTH_HASH[:info][:email]
          expect(user.name).to eq SAMPLE_AUTH_HASH[:info][:name]
          expect(user.image).to eq SAMPLE_AUTH_HASH[:info][:image]
          expect(user.token).to eq SAMPLE_AUTH_HASH[:credentials][:token]
          expect(user.expires_at)
            .to eq SAMPLE_AUTH_HASH[:credentials][:expires_at]
        end
      end

      context 'user does not already exist' do
        it 'creates the user' do
          expect { post :create }.to change { User.count }.from(0).to(1)
          user = User.first

          expect(user.email).to eq SAMPLE_AUTH_HASH[:info][:email]
          expect(user.name).to eq SAMPLE_AUTH_HASH[:info][:name]
          expect(user.image).to eq SAMPLE_AUTH_HASH[:info][:image]
          expect(user.token).to eq SAMPLE_AUTH_HASH[:credentials][:token]
          expect(user.expires_at)
            .to eq SAMPLE_AUTH_HASH[:credentials][:expires_at]
        end
      end

      it 'redirects to the communities_path afterwards' do
        post :create
        expect(response).to redirect_to communities_path
        expect(flash[:notice]).to eq "Welcome #{User.first.name}"
      end
    end

    describe 'unsuccessful create' do
      it 'redirects to the root path with notice' do
        request.env['omniauth.auth'] = { info: {}, credentials: {} }

        post :create

        expect(response).to redirect_to '/'
        expect(flash[:notice]).to eq 'Error occured setting up your account!!'
      end
    end
  end
end
