require 'rails_helper'
require 'support/dummy_facebook_service'

RSpec.describe CommunitiesController, type: :controller do
  let(:user) { create(:user) }
  let(:dummy_service) { DummyFacebookService.new }
  let(:valid_session) { { user_id: user.id } }
  let(:graph_info) do
    attributes_for(:community,
                   name: 'Asgard',
                   icon: 'my-icon.png',
                   cover: { source: 'my-cover-image.jpg' },
                   id: 'my-fbid',
                   fbid: 'my-fbid').stringify_keys
  end

  before(:each) do
    stub_const('FacebookService', dummy_service)
    dummy_service.admin_communities = [graph_info]
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
    context 'when community does not exist' do
      it 'redirects to the communities path' do
        get :edit, params: { id: 404 }, session: valid_session

        expect(response).to redirect_to communities_path
        expect(flash[:notice]).to eq 'Community not found'
      end
    end

    describe 'when community does exist' do
      let(:community) { create(:community) }

      context 'user is subscribed as admin' do
        before { user.admin_profile.add_community(community) }

        it 'returns a success response' do
          get :edit, params: { id: community.id }, session: valid_session
          expect(response).to be_successful
        end
      end

      context 'user is not subscribed as admin' do
        it 'redirects to the communities path' do
          get :edit, params: { id: community.id }, session: valid_session
          expect(response).to redirect_to communities_path
          expect(flash[:notice]).to eq 'Community not found'
        end
      end
    end
  end

  describe 'GET #create' do
    let(:fbid) { graph_info['id'] }

    describe "community doesn't exist" do
      it 'creates the community' do
        expect { post :create, params: { fbid: fbid }, session: valid_session }
          .to change { Community.count }.from(0).to(1)

        community = Community.first
        expect(community.fbid).to eq graph_info['id']
        expect(community.name).to eq graph_info['name']
        expect(community.icon).to eq graph_info['icon']
        expect(community.cover).to eq graph_info.dig('cover', 'source')
      end

      it 'adds the user as community admin' do
        post :create, params: { fbid: fbid }, session: valid_session
        expect(Community.first.admin_profiles).to eq [user.admin_profile]
      end

      it 'adds the user as community member' do
        post :create, params: { fbid: fbid }, session: valid_session
        expect(Community.first.member_profiles).to eq [user.member_profile]
      end

      describe 'notification' do
        let(:worker) { MessengerNotificationWorker }

        context 'user has psid' do
          before { user.update!(psid: 1267) }

          it 'schedules a messenger notification job for the user' do
            expect do
              post :create, params: { fbid: fbid }, session: valid_session
            end.to change { worker.jobs.size }.from(0).to(1)

            expect(worker.jobs.first['args']).to match_array(
              ['send_community_added', user.id, Community.first.id]
            )
          end
        end

        context 'user has no psid' do
          before { user.update!(psid: nil) }

          it 'does not schedule a messenger notification job' do
            expect do
              post :create, params: { fbid: fbid }, session: valid_session
            end.not_to(change { worker.jobs })
          end
        end
      end
    end

    describe 'community does exist' do
      subject! { create(:community, graph_info.merge(name: 'community-one')) }

      it 'updates the community attributes' do
        expect(subject.name).to eq 'community-one'

        expect do
          post :create, params: { fbid: subject.fbid }, session: valid_session
        end.not_to(change { Community.count })

        expect(subject.reload.name).to eq 'Asgard'
        expect(subject.icon).to eq graph_info['icon']
        expect(subject.cover).to eq graph_info.dig('cover', 'source')
      end

      context 'user is not community admin' do
        it 'adds the user as community admin' do
          expect(subject.admin_profiles).to be_empty

          post :create, params: { fbid: subject.fbid }, session: valid_session
          expect(subject.reload.admin_profiles).to eq [user.admin_profile]
        end
      end

      context 'user is community admin' do
        it "doesn't double add the user as community admin" do
          user.admin_profile.add_community(subject)

          expect do
            post :create, params: { fbid: subject.fbid }, session: valid_session
          end.not_to(change { subject.admin_profiles })

          expect(subject.reload.admin_profiles).to eq [user.admin_profile]
        end
      end

      context 'user is not community member' do
        it 'adds the user as community member' do
          post :create, params: { fbid: fbid }, session: valid_session
          expect(Community.first.member_profiles).to eq [user.member_profile]
        end
      end

      context 'user is community member' do
        it "doesn't double add the user as community admin" do
          user.member_profile.add_community(subject)

          expect do
            post :create, params: { fbid: fbid }, session: valid_session
          end.not_to(change { subject.member_profiles })

          expect(subject.reload.member_profiles).to eq [user.member_profile]
        end
      end

      describe 'notification' do
        let(:worker) { MessengerNotificationWorker }

        context 'user has psid' do
          before { user.update!(psid: 1267) }

          it 'schedules a messenger notification job for the user' do
            expect(worker.jobs.size).to be 0
            post :create, params: { fbid: subject.fbid }, session: valid_session
            expect(worker.jobs.size).to be 1
            expect(worker.jobs.first['args']).to match_array(
              ['send_community_added', user.id, Community.first.id]
            )
          end
        end

        context 'user has no psid' do
          before { user.update!(psid: nil) }

          it 'does not schedule a messenger notification job' do
            expect(worker.jobs.size).to be 0
            post :create, params: { fbid: subject.fbid }, session: valid_session
            expect(worker.jobs.size).to be 0
          end
        end
      end
    end

    context 'error occurs' do
      it 'redirects to communities path' do
        post :create, params: { fbid: 404 }, session: valid_session
        expect(response).to redirect_to communities_path
      end
    end

    context 'no error occurs' do
      it 'returns a success response' do
        post :create, params: { fbid: fbid }, session: valid_session
        expect(response).to redirect_to edit_community_path(Community.last)
      end
    end
  end

  describe 'PATCH #update' do
    context 'when community does not exist' do
      it 'redirects to the communities path' do
        patch :update, params: { id: 404 }, session: valid_session

        expect(response).to redirect_to communities_path
        expect(flash[:notice]).to eq 'Community not found'
      end
    end

    context 'when community does exist but user is not admin' do
      let(:community) { create(:community, community_type: nil) }

      it 'redirects to the communities path' do
        patch :update, params: { id: community.id }, session: valid_session

        expect(response).to redirect_to communities_path
        expect(flash[:notice]).to eq 'Community not found'
      end
    end

    context 'when community does exists and user is admin' do
      let(:community) { create(:community, community_type: nil) }
      let(:community_type) { create(:community_type) }

      before { user.admin_profile.add_community(community) }
      describe 'valid params' do
        it 'updates the community attributes' do
          expect(community.community_type).to be nil

          patch :update,
                params: {
                  id: community.id,
                  community: { community_type_id: community_type.id }
                },
                session: valid_session

          expect(community.reload.community_type).to eq community_type
        end

        describe 'handle_community_type_changed' do
          let(:type_1) { create(:community_type) }
          let(:type_2) { create(:community_type) }
          let(:worker) { MessengerNotificationWorker }

          before do
            create_list :community_type_feed_category, 2, community_type: type_1
            create_list :community_type_feed_category, 2, community_type: type_2
            community.update!(community_type: type_1)

            @profile = user.member_profile.add_community(community)
            expect(type_1.feed_categories).not_to eq type_2.feed_categories
            expect(@profile.feed_categories).to eq type_1.feed_categories
            expect(worker.jobs.size).to be 0
          end

          context 'community_type was updated' do
            before do
              patch :update,
                    params: {
                      id: community.id,
                      community: { community_type_id: type_2.id }
                    },
                    session: valid_session
            end

            it 'replaces member profile subscription with the new ones' do
              expect(@profile.reload.feed_categories)
                .to eq type_2.feed_categories
            end

            it 'schedules a notification job to inform community members' do
              expect(worker.jobs.size).to be 1
              expect(worker.jobs.first['args'])
                .to match_array(['send_community_type_changed', community.id])
            end
          end

          context 'community type was not updated' do
            before do
              patch :update,
                    params: {
                      id: community.id,
                      community: { community_type_id: type_1.id }
                    },
                    session: valid_session
            end

            it 'does not replaces member profile subscription' do
              expect(@profile.reload.feed_categories)
                .to eq type_1.feed_categories
            end

            it 'does not schedule a notification job' do
              expect(worker.jobs.size).to eq 0
            end
          end
        end
      end

      xdescribe 'invalid params' do
        it 'does not update the community attributes' do
          expect(community.community_type).to be nil

          patch :update,
                params: {
                  id: community.id,
                  community: { community_type_id: 404 }
                },
                session: valid_session

          expect(community.reload.community_type).to be nil
        end

        it 'renders the edit template' do
          expect(community.community_type).to be nil

          patch :update,
                params: {
                  id: community.id,
                  community: { community_type_id: 404 }
                },
                session: valid_session

          expect(response).to render :edit
        end
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
        user.member_profile.add_community(community)
        expect(user.admin_profile_communities).to include community
        expect(user.member_profile_communities).to include community
      end

      it 'removes the community from user admin profile' do
        expect do
          delete :destroy, params: { id: community.id }, session: valid_session
        end.to change { user.admin_profile_community_count }.from(1).to(0)

        expect(user.reload.admin_profile_communities).to be_empty
        msg = "Your '#{community.name}' community subscription has been removed"
        expect(flash[:notice]).to eq msg
      end

      it 'removes the community from user member profile' do
        expect do
          delete :destroy, params: { id: community.id }, session: valid_session
        end.to change { user.member_profile_community_count }.from(1).to(0)

        expect(user.reload.member_profile_communities).to be_empty
        msg = "Your '#{community.name}' community subscription has been removed"
        expect(flash[:notice]).to eq msg
      end

      context 'when community has no associated admin profile' do
        it 'removes the community' do
          expect do
            delete :destroy, params: { id: community.id }, session: valid_session
          end.to change { Community.count }.from(1).to(0)
        end

        it 'schedules a messenger notification to all member profiles' do
          worker = MessengerNotificationWorker
          expect do
            delete :destroy, params: { id: community.id }, session: valid_session
          end.to change { worker.jobs.count }.from(0).to(1)
          expect(worker.jobs.first['args'])
            .to match_array(['send_community_removed', community.id])
        end
      end

      context 'when community still has associated admin profile' do
        let(:user_two) { create(:user) }

        before do
          user_two.admin_profile.add_community(community)
          expect(community.admin_profiles)
            .to match_array([user.admin_profile, user_two.admin_profile])
        end

        it 'does not remove the community' do
          expect do
            delete :destroy, params: { id: community.id }, session: valid_session
          end.not_to(change { Community.count })

          expect(community.reload.admin_profiles).to eq [user_two.admin_profile]
        end

        it 'does not schedules a messenger notification' do
          worker = MessengerNotificationWorker
          expect do
            delete :destroy, params: { id: community.id }, session: valid_session
          end.not_to(change { worker.jobs.count })
        end
      end
    end
  end
end
