require 'rails_helper'
require 'support/dummy_facebook_service'

RSpec.describe CommunitiesController, type: :controller do
  let(:user) { create(:user) }
  let(:dummy_service) { DummyFacebookService.new }
  let(:valid_session) { { user_id: user.id } }
  let(:fb_community) do
    attributes_for(:community,
                   name: 'Asgard',
                   id: 'my-fbid',
                   fbid: 'my-fbid').stringify_keys
  end

  before(:each) do
    stub_const('FacebookService', dummy_service)
    dummy_service.admin_communities = [fb_community]
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    context 'when community does not exist' do
      it 'redirects to the communities path' do
        get :show, params: { id: 404 }, session: valid_session

        expect(response).to redirect_to communities_path
        expect(flash[:notice]).to eq 'Community not found'
      end
    end

    describe 'when community does exist' do
      let(:community) { create(:community) }

      context 'user is subscribed as admin' do
        before { user.admin_profile.add_community(community) }

        it 'returns a success response' do
          get :show, params: { id: community.id }, session: valid_session
          expect(response).to be_successful
        end
      end

      context 'user is not subscribed as admin' do
        it 'redirects to the communities path' do
          get :show, params: { id: community.id }, session: valid_session
          expect(response).to redirect_to communities_path
          expect(flash[:notice]).to eq 'Community not found'
        end
      end
    end
  end

  describe 'GET #edit' do
    describe "community doesn't exist" do
      it 'creates the community' do
        expect do
          get :edit, params: { id: fb_community['id'] }, session: valid_session
        end.to change { Community.count }.from(0).to(1)

        community = Community.first
        expect(community.fbid).to eq fb_community['id']
        expect(community.name).to eq fb_community['name']
      end

      it 'adds the user as community admin' do
        get :edit, params: { id: fb_community['id'] }, session: valid_session
        expect(Community.first.admin_profiles).to eq [user.admin_profile]
      end
    end

    describe 'community does exist' do
      subject! do
        create(:community, fb_community.merge(name: 'community-one'))
      end

      it 'updates the community attributes' do
        expect(subject.name).to eq 'community-one'

        expect do
          get :edit, params: { id: subject.fbid }, session: valid_session
        end.not_to(change { Community.count })

        expect(subject.reload.name).to eq 'Asgard'
      end

      context 'user is not community admin' do
        it 'adds the user as community admin' do
          expect(subject.admin_profiles).to be_empty

          get :edit, params: { id: subject.fbid }, session: valid_session
          expect(subject.reload.admin_profiles).to eq [user.admin_profile]
        end
      end

      context 'user is community admin' do
        it "doesn't double add the user as community admin" do
          user.admin_profile.add_community(subject)

          expect do
            get :edit, params: { id: subject.fbid }, session: valid_session
          end.not_to(change { subject.admin_profiles })

          expect(subject.reload.admin_profiles).to eq [user.admin_profile]
        end
      end
    end

    context 'error occurs' do
      it 'redirects to communities path' do
        get :edit, params: { id: 404 }, session: valid_session
        expect(response).to redirect_to communities_path
      end
    end

    context 'no error occurs' do
      it 'returns a success response' do
        get :edit, params: { id: fb_community['id'] }, session: valid_session
        expect(response).to be_successful
      end
    end
  end
end
