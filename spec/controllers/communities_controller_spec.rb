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

  describe 'DELETE #destroy' do
    context 'when community does not exist' do
      it 'redirects to communities path' do
        delete :destroy, params: { id: 404 }, session: valid_session
        expect(response).to redirect_to communities_path
        expect(flash[:notice]).to eq 'Community not found'
      end
    end

    context 'when community exists' do
      let(:community) { create(:community) }
      before(:each) do
        user.admin_profile.add_community(community)
        expect(user.admin_communities).to include community
      end

      it 'removes the community from user admin profile' do
        expect do
          delete :destroy, params: { id: community.id }, session: valid_session
        end.to change { user.admin_profile.communities.count }.from(1).to(0)

        expect(user.reload.admin_communities).to be_empty
        msg = "Your '#{community.name}' community subscription has been removed"
        expect(flash[:notice]).to eq msg
      end

      context 'when community has no associated admin profile' do
        it 'removes the community' do
          expect do
            delete :destroy, params: { id: community.id }, session: valid_session
          end.to change { Community.count }.from(1).to(0)
        end
      end

      context 'when community still has associated admin profile' do
        let(:user_two) { create(:user) }

        before do
          user_two.admin_profile.add_community(community)
          expect(community.admin_profiles)
            .to match_array([user.admin_profile ,user_two.admin_profile])
        end

        it 'does not remove the community' do
          expect do
            delete :destroy, params: { id: community.id }, session: valid_session
          end.not_to(change { Community.count })

          expect(community.reload.admin_profiles).to eq [user_two.admin_profile]
        end
      end
    end
  end
end
