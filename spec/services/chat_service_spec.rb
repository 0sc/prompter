require 'rails_helper'
require 'support/omniauth'
require 'support/dummy_facebook_service'

RSpec.describe ChatService, type: :service do
  let(:message) { double }
  let(:psid) { SAMPLE_MESSENGER_PROFILE['id'] }
  let(:find_pkg) { ChatService::FIND_COMMUNITIES }
  let(:manage_pkg) { ChatService::MANAGE_COMMUNITIES }
  let(:subscribe_pkg) { ChatService::SUBSCRIBE_COMMUNITIES }
  let(:dummy_service) { DummyFacebookService.new }

  subject { ChatService.new(message) }

  before(:each) do
    allow(message).to receive(:sender).and_return('id' => psid)
    allow_any_instance_of(User).to receive(:profile_details_from_messenger)
      .and_return(SAMPLE_MESSENGER_PROFILE)
    stub_const('FacebookService', dummy_service)
  end

  describe '.new' do
    context 'user with psid does not exist' do
      it 'creates a new user' do
        expect { subject }.to change { User.count }.from(0).to(1)
      end

      it 'updates the user details' do
        user = subject.user
        expect(user.persisted?).to be true

        first_name = SAMPLE_MESSENGER_PROFILE['first_name']
        last_name = SAMPLE_MESSENGER_PROFILE['last_name']
        name = "#{first_name} #{last_name}"
        temp_email = "#{psid}#{MessengerProfile::EMAIL_PLACEHOLDER_HOST}"

        expect(user.fbid).to eq SAMPLE_MESSENGER_PROFILE['id'].to_i
        expect(user.name).to eq name
        expect(user.email).to eq temp_email
        expect(user.image).to eq SAMPLE_MESSENGER_PROFILE['profile_pic']
        expect(user.token).to eq MessengerProfile::TOKEN_PLACEHOLDER
        expect(user.expires_at).not_to be nil
      end
    end

    context 'user with psid already exist' do
      let!(:user) { create(:user, psid: psid) }

      it 'does not a create another user' do
        expect { subject }.not_to(change { User.count })
      end

      it 'does not update the user detail' do
        user = subject.user
        expect(user.persisted?).to be true

        first_name = SAMPLE_MESSENGER_PROFILE['first_name']
        last_name = SAMPLE_MESSENGER_PROFILE['last_name']
        name = "#{first_name} #{last_name}"
        temp_email = "#{psid}#{MessengerProfile::EMAIL_PLACEHOLDER_HOST}"

        expect(user.fbid).not_to eq SAMPLE_MESSENGER_PROFILE['id'].to_i
        expect(user.name).not_to eq name
        expect(user.email).not_to eq temp_email
        expect(user.image).not_to eq SAMPLE_MESSENGER_PROFILE['profile_pic']
        expect(user.token).not_to eq MessengerProfile::TOKEN_PLACEHOLDER
        expect(user.expires_at).not_to be nil
      end
    end
  end

  describe '#sender_id' do
    it 'returns the message sender id' do
      expect(subject.sender_id).to eq message.sender['id']
    end
  end

  describe '#username' do
    it 'returns the first name of the user' do
      expect(subject.username).to eq subject.user.first_name
    end
  end

  describe '#cta_options' do
    context 'user is subscribed' do
      before(:each) do
        subject.user.member_profile.add_community(create(:community))
      end

      it 'includes the manage subscription option' do
        expect(subject.cta_options).to match_array(
          [find_pkg, subscribe_pkg, manage_pkg]
        )
      end
    end

    context 'user is not subscribed' do
      it 'does not include the manage subscription option' do
        expect(subject.cta_options)
          .to match_array([find_pkg, subscribe_pkg])
      end
    end
  end

  describe '#handle' do
    let(:user) { subject.user }

    before(:each) do
      attrs = attributes_for(:user).except(:id, :psid)
      subject.user.update!(attrs)
    end

    describe 'find-community payload' do
      context 'user account is not linked' do
        before(:each) { user.update(fbid: user.psid) } # fail acc linking test

        it 'responds with the link account cta' do
          expect(Responder).to receive(:send_link_account_cta).with(subject)
          subject.handle(find_pkg)
        end
      end

      context 'user account access_token is expired' do
        before(:each) { user.update(expires_at: 2.days.ago.to_i) }

        it 'responds with renew token cta' do
          expect(Responder).to receive(:send_renew_token_cta).with(subject)
          subject.handle(find_pkg)
        end
      end

      describe 'user account is in good shape' do
        let(:already_subded) do
          create(:community).tap { |c| user.member_profile.add_community(c) }
        end
        let(:not_subbed) { create(:community) }
        let(:not_added) { build(:community) }

        before(:each) do
          # avoid token expiring
          user.update(expires_at: Time.now.in(10.years).tv_sec)
          dummy_service.communities = [
            graph_representation_of(already_subded),
            graph_representation_of(not_subbed),
            graph_representation_of(not_added)
          ]
        end

        context 'there are no communities to subscribe' do
          before(:each) { not_subbed.destroy }

          it 'responds with the no_community_to_subscribe_cta' do
            expect(Responder)
              .to receive(:send_no_community_to_subscribe_cta).with(subject)
            subject.handle(find_pkg)
          end

          describe 'cta_options' do
            before(:each) do
              expect(Responder)
                .to receive(:send_no_community_to_subscribe_cta) { subject }
            end

            context 'user is subscribed' do
              it 'sets it to subscribe-community and manage-community' do
                subject.handle(find_pkg)
                expect(subject.cta_options)
                  .to match_array([subscribe_pkg, manage_pkg])
              end

              it 'sets it only to subscribe-community' do
                already_subded.destroy
                user.reload

                subject.handle(find_pkg)
                expect(subject.cta_options).to match_array([subscribe_pkg])
              end
            end
          end
        end

        context 'there are communities to subscribe' do
          let(:svc) { Chat::PostbackService }

          describe 'response' do
            context 'one subscribable community' do
              it 'responds with a button template' do
                postback = svc.build_subscribe_to_community_postback(
                  not_subbed.id
                )
                payload = {
                  title: not_subbed.name,
                  subtitle: "#{not_subbed.feed_categories.count} categories",
                  image: not_subbed.cover,
                  postback: postback
                }

                mtd = :send_single_community_to_subscribe_cta
                expect(Responder).to receive(mtd).with(subject, payload)
                subject.handle(find_pkg)
              end
            end

            context 'less than 5 subscribable communities' do
              let(:communities) { create_list(:community, 4) }

              before(:each) do
                dummy_service.communities = communities.map do |community|
                  graph_representation_of(community)
                end
              end

              it 'responds with list template' do
                payload = communities.map do |c|
                  postback = svc.build_subscribe_to_community_postback(c.id)
                  {
                    title: c.name,
                    subtitle: "#{c.feed_categories.count} categories",
                    image: c.cover,
                    postback: postback
                  }
                end

                mtd = :send_communities_to_subscribe_cta
                expect(Responder).to receive(mtd).with(subject, payload)
                subject.handle(find_pkg)
              end
            end

            context 'more than 4 subscribable communities' do
              let(:communities) { create_list(:community, 9) }

              before(:each) do
                dummy_service.communities = communities.map do |community|
                  graph_representation_of(community)
                end
              end

              it 'responds multiple times if more than 4' do
                payload = communities.map do |c|
                  postback = svc.build_subscribe_to_community_postback(c.id)
                  {
                    title: c.name,
                    image: c.cover,
                    subtitle: "#{c.feed_categories.count} categories",
                    postback: postback
                  }
                end

                mtd = :send_communities_to_subscribe_cta
                payload.first(8).each_slice(4) do |p|
                  expect(Responder).to receive(mtd).once.ordered.with subject, p
                end

                mtd = :send_single_community_to_subscribe_cta
                expect(Responder)
                  .to receive(mtd).once.ordered.with(subject, payload.last)
                subject.handle(find_pkg)
              end
            end
          end
        end
      end
    end

    describe 'subscribe-community payload' do
      context 'user account is not linked' do
        before(:each) { user.update(fbid: user.psid) } # fail acc linking test

        it 'responds with the link account cta' do
          expect(Responder).to receive(:send_link_account_cta).with(subject)
          subject.handle(subscribe_pkg)
        end
      end

      context 'user account access_token is expired' do
        before(:each) { user.update(expires_at: 2.days.ago) }

        it 'responds with renew token cta' do
          expect(Responder).to receive(:send_renew_token_cta).with(subject)
          subject.handle(subscribe_pkg)
        end
      end

      context 'user account is in good shape' do
        before(:each) { user.update(expires_at: Time.now.in(10.years).tv_sec) }

        it 'responds with the send_subscribe_communities_cta' do
          expect(Responder)
            .to receive(:send_subscribe_communities_cta).with(subject)
          subject.handle(subscribe_pkg)
        end
      end
    end

    describe 'manage-communities payload' do
      context 'user has no subscriptions' do
        before(:each) do
          user.member_profile.community_member_profiles.map(&:destroy)
        end

        it 'responds with the no subscription cta' do
          expect(Responder).to receive(:send_no_subscription_cta).with(subject)
          subject.handle(manage_pkg)
        end
      end

      context 'user has subscriptions' do
        let(:profile) do
          create(:community_member_profile, member_profile: user.member_profile)
        end

        it 'responds with the communities_to_manage_cta' do
          payload = {
            title: profile.community_name,
            image: profile.community.cover,
            subtitle: profile.subscribed_feed_category_summary,
            url: "/community_member_profiles/#{profile.id}/edit"
          }

          expect(Responder).to receive(:send_communities_to_manage_cta)
            .with(subject, [payload])
          subject.handle(manage_pkg)
        end

        describe 'response' do
          it 'sends it in batches of 10' do
            profiles = create_list(:community_member_profile, 21,
                                   member_profile: user.member_profile)
            payload = profiles.map do |profile|
              {
                title: profile.community_name,
                image: profile.community.cover,
                subtitle: profile.subscribed_feed_category_summary,
                url: "/community_member_profiles/#{profile.id}/edit"
              }
            end

            payload.each_slice(10) do |p|
              expect(Responder).to receive(:send_communities_to_manage_cta)
                .once.ordered.with(subject, p)
            end

            subject.handle(manage_pkg)
          end
        end
      end
    end
  end

  def graph_representation_of(comm)
    {
      name: comm.name,
      icon: comm.icon,
      cover: { source: comm.cover },
      id: comm.fbid,
      fbid: comm.fbid
    }.stringify_keys
  end
end
