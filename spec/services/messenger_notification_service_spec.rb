require 'rails_helper'

RSpec.describe MessengerNotificationService, type: :service do
  subject { MessengerNotificationService }
  let(:user) { create(:user) }
  let(:community) { create(:community) }

  describe '.send_community_added' do
    context 'user does not exist' do
      it 'returns nil' do
        expect(subject.send_community_added(404, community.id)).to be nil
      end
    end

    context 'user does not have psid' do
      before { user.update(psid: nil) }

      it 'returns nil' do
        expect(subject.send_community_added(user.id, community.id)).to be nil
      end
    end

    context 'community does not exist' do
      it 'returns nil' do
        expect(subject.send_community_added(user.id, 404)).to be nil
      end
    end

    context 'community is not in user admin communities' do
      it 'returns nil' do
        expect(subject.send_community_added(user.id, community.id)).to be nil
      end
    end

    context 'all is well' do
      before { user.admin_profile.add_community(community) }

      it 'sends the community added response' do
        expect(Notifier).to receive(:send_community_added_notice)
          .with(
            psid: user.psid,
            name: community.name,
            ref_link: community.referral_link
          )

        subject.send_community_added(user.id, community.id)
      end
    end
  end

  describe '.send_community_type_changed' do
    context 'community does not exist' do
      it 'returns nil' do
        expect(subject.send_community_type_changed(404)).to be nil
      end
    end

    context 'all is well' do
      let(:notifier_attrs) do
        lambda do |profile|
          {
            psid: profile.member_profile.user.psid,
            pid: profile.id,
            name: community.name,
            type: community.community_type_name,
            info: profile.subscribed_feed_category_summary
          }
        end
      end

      it 'sends the community added response to all member of the community' do
        create_list(:community_member_profile, 2, community: community)
          .each do |prof|
            expect(Notifier).to receive(:send_community_type_changed_notice)
              .once.ordered.with notifier_attrs.call(prof)
          end

        subject.send_community_type_changed(community.id)
      end
    end
  end

  describe '.send_community_removed' do
    context 'community does not exist' do
      it 'returns nil' do
        expect(subject.send_community_removed(404)).to be_nil
      end
    end

    context 'all is well' do
      let(:notifier_attrs) do
        lambda do |profile|
          { psid: profile.member_profile.user.psid, name: community.name }
        end
      end

      it 'sends the community removed notification to all member of the comm' do
        create_list(:community_member_profile, 2, community: community)
          .each do |prof|
            expect(Notifier).to receive(:send_community_removed_notice)
              .once.ordered.with notifier_attrs.call(prof)
          end

        subject.send_community_removed(community.id)
      end
    end
  end

  describe '.send_community_profile_deleted' do
    context 'user does not exist' do
      it 'returns nil' do
        expect(subject.send_community_added(404, community.id)).to be nil
      end
    end

    context 'user does not have psid' do
      before { user.update(psid: nil) }

      it 'returns nil' do
        expect(subject.send_community_added(user.id, community.id)).to be nil
      end
    end

    context 'community does not exist' do
      it 'returns nil' do
        expect(subject.send_community_added(user.id, 404)).to be nil
      end
    end

    context 'all is well' do
      it 'sends a send_community_profile_deleted_notice' do
        expect(Notifier).to receive(:send_community_profile_deleted_notice)
          .with(psid: user.psid, name: community.name)

        subject.send_community_profile_deleted(user.id, community.id)
      end
    end
  end

  describe '.send_community_profile_updated' do
    context 'community profile does not exist' do
      it 'returns nil' do
        expect(subject.send_community_profile_updated(404)).to be nil
      end
    end

    context 'community profile exists' do
      let(:profile) do
        create(:community_member_profile, member_profile: user.member_profile)
      end

      it 'triggers the send_community_profile_updated_notice' do
        expect(Notifier).to receive(:send_community_profile_updated_notice)
          .with(
            psid: profile.member_profile.user.psid,
            info: profile.subscribed_feed_category_summary
          )

        subject.send_community_profile_updated(profile.id)
      end
    end
  end

  describe '.send_access_token_expiring' do
    context 'user does not exist' do
      it 'returns nil' do
        expect(subject.send_access_token_expiring(404)).to be nil
      end
    end

    context 'user does not have psid' do
      before { user.update(psid: nil) }

      it 'returns nil' do
        expect(subject.send_access_token_expiring(user.id)).to be nil
      end
    end

    context 'user exists' do
      it 'triggers the send_access_token_expiring_notice' do
        expect(Notifier).to receive(:send_access_token_expiring_notice)
          .with(psid: user.psid, num_admin_comms: user.admin_communities.count)

        subject.send_access_token_expiring(user.id)
      end
    end
  end

  describe '.send_access_token_expired' do
    context 'user does not exist' do
      it 'returns nil' do
        expect(subject.send_access_token_expired(404)).to be nil
      end
    end

    context 'user does not have psid' do
      before { user.update(psid: nil) }

      it 'returns nil' do
        expect(subject.send_access_token_expired(user.id)).to be nil
      end
    end

    context 'user exists' do
      it 'triggers the send_access_token_expired_notice' do
        expect(Notifier).to receive(:send_access_token_expired_notice)
          .with(psid: user.psid, num_admin_comms: user.admin_communities.count)

        subject.send_access_token_expired(user.id)
      end
    end
  end
end
