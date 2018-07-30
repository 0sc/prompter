require 'rails_helper'
require 'support/omniauth'

module FakeRouter
  class Route < ::Rails::Engine
    # isolate_namespace FakeRouter
  end

  Route.routes.draw do
    root 'users#new'
    resources :users, only: :create
    get '/auth/:provider/failed', to: 'users#failed'
    resources :communities
  end
end

RSpec.describe UsersController, type: :controller do
  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'redirects to community path if user is logged in' do
      get :new, params: {}, session: { user_id: create(:user).id }
      expect(response).to redirect_to communities_path
    end
  end

  describe 'POST #create' do
    before do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
    end

    routes { FakeRouter::Route.routes }

    describe 'successful create' do
      context 'user already exists with facebook profile' do
        let!(:user) { create(:user, email: SAMPLE_AUTH_HASH[:info][:email]) }

        it 'does not duplicate user record' do
          expect { post :create }.not_to(change { User.count })
        end

        it 'updates the user attributes' do
          post :create
          user.reload
          %i[email name image].each do |attr|
            expect(user[attr]).to eq SAMPLE_AUTH_HASH[:info][attr]
          end
          %i[token expires_at].each do |attr|
            expect(user[attr]).to eq SAMPLE_AUTH_HASH[:credentials][attr]
          end
        end
      end

      context 'user already exists with messenger profile' do
        let(:fbid) { SAMPLE_AUTH_HASH[:uid] }
        let!(:user) { create(:user, fbid: fbid, psid: 1_235_678) }

        it 'does not duplicate user record' do
          expect { post :create, params: {}, session: { user_id: user.id } }
            .not_to(change { User.count })
        end

        it 'updates the user attributes' do
          post :create, params: {}, session: { user_id: user.id }
          user.reload
          %i[email name image].each do |attr|
            expect(user[attr]).to eq SAMPLE_AUTH_HASH[:info][attr]
          end
          %i[token expires_at].each do |attr|
            expect(user[attr]).to eq SAMPLE_AUTH_HASH[:credentials][attr]
          end
        end
      end

      context 'user already exists with different messenger and fb profiles' do
        let(:fbid) { SAMPLE_AUTH_HASH[:uid] }
        let!(:fb_acc) do
          create(:user,
                 image: nil,
                 email: SAMPLE_AUTH_HASH[:info][:email],
                 psid: nil)
        end
        let!(:msg_acc) { create(:user) }

        it 'deletes the messenger profile' do
          expect { post :create, params: {}, session: { user_id: msg_acc.id } }
            .to change { User.count }.from(2).to(1)
        end

        it 'consolidates the fb profile with the messenger profile info' do
          post :create, params: {}, session: { user_id: msg_acc.id }
          fb_acc.reload
          expect(fb_acc.psid).to eq msg_acc.psid
          expect(fb_acc.image).to eq msg_acc.image
        end

        it 'updates the fb profile attributes' do
          post :create, params: {}, session: { user_id: msg_acc.id }
          fb_acc.reload
          %i[email name image].each do |attr|
            expect(fb_acc[attr]).to eq SAMPLE_AUTH_HASH[:info][attr]
          end
          %i[token expires_at].each do |attr|
            expect(fb_acc[attr]).to eq SAMPLE_AUTH_HASH[:credentials][attr]
          end
        end
      end

      context 'user does not already exist' do
        it 'creates the user' do
          expect { post :create }.to change { User.count }.from(0).to(1)
          user = User.first

          %i[email name image].each do |attr|
            expect(user[attr]).to eq SAMPLE_AUTH_HASH[:info][attr]
          end
          %i[token expires_at].each do |attr|
            expect(user[attr]).to eq SAMPLE_AUTH_HASH[:credentials][attr]
          end
        end
      end

      describe 'redirect' do
        context 'account linking' do
          it 'redirects to the session rdr afterwards' do
            uri = 'https://fb.com/bot/way?code=green'
            payload = '&authorization_code=account-linked-successfully'
            post :create, params: {}, session: { rdr: uri }
            expect(response).to redirect_to "#{uri}#{payload}"
            expect(flash[:notice]).to eq "Welcome #{User.first.name}"
          end
        end

        context 'not account linking' do
          it 'redirects to the communities_path afterwards' do
            post :create
            expect(response).to redirect_to communities_path
            expect(flash[:notice]).to eq "Welcome #{User.first.name}"
          end
        end
      end
    end

    describe 'unsuccessful create' do
      let(:notice) { 'Error occured setting up your account!' }
      before { request.env['omniauth.auth'] = { info: {}, credentials: {} } }

      describe 'redirect' do
        context 'account linking' do
          it 'redirects to the session rdr afterwards' do
            uri = 'https://fb.com/bot/way?code=red'
            post :create, params: {}, session: { rdr: uri }
            expect(response).to redirect_to uri
            expect(flash[:notice]).to eq notice
          end
        end

        context 'not account linking' do
          it 'redirects to the root path with notice' do
            post :create

            expect(response).to redirect_to root_path
            expect(flash[:notice]).to eq notice
          end
        end
      end
    end

    describe 'clear_session' do
      context 'account_linking?' do
        it 'clears the account linking session vars' do
          post :create, params: {}, session: { rdr: 'something', alt: 'herre' }
          expect(session['alt']).to eql nil
          expect(session['rdr']).to eql nil
        end
      end

      context 'not account linking' do
        it 'does not clear the session vars' do
          post :create, params: {}, session: { alt: 'herre' }
          expect(session['alt']).to eql 'herre'
        end
      end
    end
  end

  describe 'GET #account_link' do
    context 'invalid user' do
      it 'redirects to root_path' do
        get :account_link, params: { psid: 404 }
        expect(response).to redirect_to root_path
      end
    end

    context 'valid user' do
      subject { create(:user) }

      it 'sets account linking session variables' do
        get :account_link,
            params: {
              psid: subject.psid,
              redirect_uri: 'https://somewhere.deep/on/fb',
              account_linking_token: 'fb-super-secret-token'
            }
        expect(session[:rdr]).to eq 'https://somewhere.deep/on/fb'
        expect(session['alt']).to eq 'fb-super-secret-token'
      end

      it 'redirects to fb auth route' do
        get :account_link, params: { psid: subject.psid }
        expect(response).to redirect_to '/auth/facebook'
      end
    end
  end

  describe 'GET #failed' do
    routes { FakeRouter::Route.routes }

    let(:notice) { 'Error occured setting up your account!' }
    before { request.env['omniauth.auth'] = { info: {}, credentials: {} } }

    context 'account linking' do
      it 'redirects to the session rdr afterwards' do
        uri = 'https://fb.com/bot/way?code=red'
        get :failed, params: { provider: 'facebook' }, session: { rdr: uri }
        expect(response).to redirect_to uri
        expect(flash[:notice]).to eq notice
      end
    end

    context 'not account linking' do
      it 'redirects to the root path with notice' do
        get :failed, params: { provider: 'facebook' }

        expect(response).to redirect_to root_path
        expect(flash[:notice]).to eq notice
      end
    end
  end

  describe 'GET #login' do
    let(:user) { create(:user) }

    context 'session' do
      it 'sets the user_id session key if user with psid exists' do
        get :login, params: { id: user.psid }
        expect(session[:user_id]).to eq user.id
      end

      it 'does not set the user_id session key if user does not exist' do
        get :login, params: { id: 404 }
        expect(session[:user_id]).to be nil
      end
    end

    context 'redirect' do
      it 'redirects to the session target_page if present' do
        get :login, params: { id: user.psid }, session: { target_page: 'random' }
        expect(response).to redirect_to 'random'
      end

      it 'redirects to the root path is session target page is not present' do
        get :login, params: { id: user.psid }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET #logout' do
    it 'clears all session variables' do
      get :logout, params: {}, session: { user_id: 100, target_page: 'here' }
      expect(session.keys).to be_empty
    end

    it 'redirects to the root path' do
      get :logout
      expect(response).to redirect_to root_path
    end
  end
end
