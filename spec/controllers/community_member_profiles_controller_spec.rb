require 'rails_helper'

RSpec.describe CommunityMemberProfilesController, type: :controller do
  let(:user) { create(:user) }
  let(:community) { create(:community, :with_feed_categories, amount: 3) }
  let(:valid_session) { { user_id: user.id } }
  let(:params) do
    {
      id: subject.id,
      community_member_profile: {
        feed_category_ids: community.feed_categories.map(&:id)
      }
    }
  end

  subject do
    create(:community_member_profile,
           member_profile: user.member_profile,
           community: community
         )
  end

  shared_examples 'set_community_member_profile' do |req, action|
    context 'community_member_profile does not exist' do
      it 'redirects to root path' do
        send req, action, params: { id: 404 }, session: valid_session
        expect(response).to redirect_to root_path
      end
    end

    context 'community_member_profile exists' do
      it 'redirects to root path if does not belong to user' do
        profile = create(:community_member_profile)
        send req, action, params: { id: profile.id }, session: valid_session
        expect(response).to redirect_to root_path
      end

      it 'does not redirect if it belongs to user' do
        profile =
          create(:community_member_profile, member_profile: user.member_profile)
        send(
          req,
          action,
          params: {
            community_member_profile: { feed_category_ids: [''] },
            id: profile.id
          },
          session: valid_session
        )
        expect(response).not_to redirect_to root_path
      end
    end
  end


  describe 'GET #show' do
    include_examples 'set_community_member_profile', :get, :show

    it 'returns a success response' do
      get :show, params: { id: subject.id }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    include_examples 'set_community_member_profile', :get, :edit

    it 'returns a success response' do
      get :edit, params: { id: subject.id }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'PATCH #update' do
    include_examples 'set_community_member_profile', :patch, :update
    before { subject.subscribe_to_all_feed_categories }

    context 'empty feed category subscription' do
      let(:params) do
        {
          id: subject.id,
          community_member_profile: { feed_category_ids: [''] }
        }
      end

      it 'destroys the community_member_profile' do
        expect(CommunityMemberProfileFeedCategory.count).to eq 3
        expect do
          patch :update, params: params, session: valid_session
        end.to change { CommunityMemberProfile.count }.from(1).to(0)
        expect(CommunityMemberProfileFeedCategory.count).to eq 0
      end

      it 'redirects to the curtain page' do
        patch :update, params: params, session: valid_session
        expect(response).to redirect_to curtain_community_member_profiles_path
      end
    end

    context 'update successful' do
      let(:params) do
        {
          id: subject.id,
          community_member_profile: {
            feed_category_ids: community.feed_categories.first(1).map(&:id)
          }
        }
      end
      it 'updates the profile feed category subscription' do
        expect(subject.reload.feed_categories).to eq community.feed_categories
        patch :update, params: params, session: valid_session

        expect(subject.reload.feed_categories)
          .to eq community.feed_categories.first(1)
      end

      it 'redirects to the community_member_profile show page' do
        patch :update, params: params, session: valid_session
        expect(response).to redirect_to community_member_profile_path(subject)
        expect(flash['notice']).to eq 'Updated successfully!'
      end
    end

    # https://github.com/rails/rails/issues/29420
    xcontext 'update fails' do
      let(:params) do
        {
          id: subject.id,
          community_member_profile: {
            feed_category_ids: [404]
          }
        }
      end
      it 'does not update the profile feed category subscription' do
        expect(subject.reload.feed_categories).to eq community.feed_categories
        patch :update, params: params, session: valid_session

        expect(subject.reload.feed_categories).to eq community.feed_categories
      end

      it 'redirects to the community_member_profile show page' do
        patch :update, params: params, session: valid_session
        expect(response).to redirect_to community_member_profile_path(subject)
      end
    end
  end

  describe 'GET #curtain' do
    it 'returns a success response' do
      get :curtain, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end
end
