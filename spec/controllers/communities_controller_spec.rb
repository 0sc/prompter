require 'rails_helper'
require 'support/dummy_facebook_service'

RSpec.describe CommunitiesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_session) { { user_id: user.id } }

  before(:each) do
    stub_const('FacebookService', DummyFacebookService)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: {}, session: valid_session
      expect(response).to be_success
    end
  end

  describe 'GET #edit' do
    describe "community doesn't exist" do
      it 'creates the community' do
        expect do
          get :edit, params: { id: 2018 }, session: valid_session
        end.to change { Community.count }.from(0).to(1)
        expect(Community.first.fbid).to eq "2018"
      end

      it 'adds the user as community admin' do
        get :edit, params: { id: 2018 }, session: valid_session
        expect(Community.first.admin_profiles).to eq [user.admin_profile]
      end
    end

    describe 'community does exist' do
      subject! { create(:community, name: 'community-one') }

      it 'updates the community attributes' do
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
            get :edit,
                params: { id: subject.fbid },
                session: valid_session
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
        get :edit, params: { id: 2018 }, session: valid_session
        expect(response).to be_success
      end
    end
  end
end
