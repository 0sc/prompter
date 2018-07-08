require 'support/omniauth'
require 'support/dummy_facebook_service'

shared_examples 'quick_reply' do
  subject { described_class.new(message) }
  let(:message) { double }
  let(:user) { subject.user }
  let(:dummy_service) { DummyFacebookService.new }

  before do
    allow_any_instance_of(User).to receive(:profile_details_from_messenger)
      .and_return(SAMPLE_MESSENGER_PROFILE)
  end

  before(:each) do
    allow(message).to receive(:sender).and_return('id' => 100)
    allow(message).to receive(:messaging).and_return(quick_reply_payload)
    stub_const('FacebookService', dummy_service)
  end

  describe '#handle_quick_reply' do
    before(:each) do
      attrs = attributes_for(:user).except(:id, :psid)
      subject.user.update!(attrs)
    end

    describe 'find-community payload' do
      before(:each) do
        allow(message).to receive(:messaging).and_return(find_community_payload)
      end

      context 'user account is not linked' do
        before(:each) { user.update(fbid: user.psid) } # fail acc linking test

        it 'responds with the link account cta' do
          expect(Responder).to receive(:send_link_account_cta).with(subject)
          subject.handle_quick_reply
        end
      end

      context 'user account access_token is expired' do
        before(:each) { user.update(expires_at: 2.days.ago) }

        it 'responds with renew token cta' do
          expect(Responder).to receive(:send_renew_token_cta).with(subject)
          subject.handle_quick_reply
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
            subject.handle_quick_reply
          end

          describe 'cta_options' do
            before(:each) do
              expect(Responder)
                .to receive(:send_no_community_to_subscribe_cta) { subject }
            end
            context 'user is subscribed' do
              it 'sets it to subscribe-community and manage-community' do
                subject.handle_quick_reply
                expect(
                  subject.instance_variable_get(:@cta_options)
                ).to match_array([Chat::QuickReply::SUBSCRIBE_COMMUNITIES,
                                  Chat::QuickReply::MANAGE_COMMUNITIES])
              end

              it 'sets it only to subscribe-community' do
                already_subded.destroy
                user.reload

                subject.handle_quick_reply
                expect(subject.cta_options)
                  .to match_array([Chat::QuickReply::SUBSCRIBE_COMMUNITIES])
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
                subject.handle_quick_reply
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
                subject.handle_quick_reply
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
                subject.handle_quick_reply
              end
            end
          end
        end
      end
    end

    describe 'subscribe-community payload' do
      before(:each) do
        allow(message)
          .to receive(:messaging).and_return(subscribe_communities_payload)
      end

      context 'user account is not linked' do
        before(:each) { user.update(fbid: user.psid) } # fail acc linking test

        it 'responds with the link account cta' do
          expect(Responder).to receive(:send_link_account_cta).with(subject)
          subject.handle_quick_reply
        end
      end

      context 'user account access_token is expired' do
        before(:each) { user.update(expires_at: 2.days.ago) }

        it 'responds with renew token cta' do
          expect(Responder).to receive(:send_renew_token_cta).with(subject)
          subject.handle_quick_reply
        end
      end

      context 'user account is in good shape' do
        before(:each) { user.update(expires_at: Time.now.in(10.years).tv_sec) }

        it 'responds with the send_subscribe_communities_cta' do
          expect(Responder)
            .to receive(:send_subscribe_communities_cta).with(subject)
          subject.handle_quick_reply
        end
      end
    end

    describe 'manage-communities payload' do
      before(:each) do
        allow(message)
          .to receive(:messaging).and_return(manage_communities_payload)
      end

      context 'user has no subscriptions' do
        before(:each) do
          user.member_profile.community_member_profiles.map(&:destroy)
        end

        it 'responds with the no subscription cta' do
          expect(Responder).to receive(:send_no_subscription_cta).with(subject)
          subject.handle_quick_reply
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
          subject.handle
        end

        describe 'response' do
          it 'sends it in batches of 10' do
            profiles = create_list(:community_member_profile,
                                   21,
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

            subject.handle_quick_reply
          end
        end
      end
    end

    describe 'everything else' do
      it 'defaults to handle msg reply' do
        expect(subject).to receive(:handle_msg_reply)
        subject.handle_quick_reply
      end
    end
  end

  def find_community_payload
    quick_reply_payload.tap do |payload|
      payload['message']['quick_reply']['payload'] =
        Chat::QuickReply::FIND_COMMUNITIES
    end
  end

  def subscribe_communities_payload
    quick_reply_payload.tap do |payload|
      payload['message']['quick_reply']['payload'] =
        Chat::QuickReply::SUBSCRIBE_COMMUNITIES
    end
  end

  def manage_communities_payload
    quick_reply_payload.tap do |payload|
      payload['message']['quick_reply']['payload'] =
        Chat::QuickReply::MANAGE_COMMUNITIES
    end
  end

  def quick_reply_payload(opts = {})
    {
      'message' => {
        'quick_reply' => { 'payload' => {} }
      }
    }.merge(opts)
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
