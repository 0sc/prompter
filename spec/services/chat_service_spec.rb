require 'rails_helper'
require 'support/omniauth'

RSpec.describe ChatService, type: :service do
  let(:message) { double }
  let(:psid) { SAMPLE_MESSENGER_PROFILE['id'] }
  subject { ChatService.new(message) }

  before(:each) do
    allow(message).to receive(:sender).and_return('id' => psid)
    allow_any_instance_of(User).to receive(:profile_details_from_messenger)
      .and_return(SAMPLE_MESSENGER_PROFILE)
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

  describe '#default_cta_options' do
    context 'user is subscribed' do
      before(:each) do
        subject.user.member_profile.add_community(create(:community))
      end

      it 'includes the manage subscription option' do
        expect(subject.default_cta_options).to match_array(
          [Chat::QuickReply::FIND_COMMUNITY,
           Chat::QuickReply::SUBSCRIBE_COMMUNITY,
           Chat::QuickReply::MANAGE_COMMUNITY]
        )
      end
    end

    context 'user is not subscribed' do
      it 'does not include the manage subscription option' do
        expect(subject.default_cta_options).to match_array(
          [Chat::QuickReply::FIND_COMMUNITY,
           Chat::QuickReply::SUBSCRIBE_COMMUNITY]
        )
      end
    end
  end
end
