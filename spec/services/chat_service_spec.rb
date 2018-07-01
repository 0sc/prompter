require 'rails_helper'
require 'support/omniauth'

RSpec.describe ChatService, type: :service do
  let(:message) { double }
  let(:psid) { SAMPLE_MESSENGER_PROFILE['id'] }

  before(:each) do
    allow(message).to receive(:sender).and_return('id' => psid)
    allow_any_instance_of(User).to receive(:profile_details_from_messenger)
      .and_return(SAMPLE_MESSENGER_PROFILE)
  end

  describe '.new' do
    context 'user with psid does not exist' do
      it 'creates a new user' do
        expect { ChatService.new(message) }
          .to change { User.count }.from(0).to(1)
      end

      it 'updates the user details' do
        user = ChatService.new(message).user
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
        expect { ChatService.new(message) }.not_to(change { User.count })
      end

      it 'does not update the user detail' do
        user = ChatService.new(message).user
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
    subject { ChatService.new(message) }

    it 'returns the message sender id' do
      expect(subject.sender_id).to eq message.sender['id']
    end
  end

  describe '#username' do
    subject { ChatService.new(message) }

    it 'returns the first name of the user' do
      expect(subject.username).to eq subject.user.first_name
    end
  end
end
