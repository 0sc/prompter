shared_examples 'messenger_profile' do
  subject { build(described_class.model_name.singular.to_sym) }

  describe 'psid validation' do
    context 'psid is not present' do
      before { subject.psid = nil }
      xit { should_not validate_uniqueness_of(:psid) }
    end

    context 'psid is present' do
      before { subject.psid = 123_456_789 }
      it { should validate_uniqueness_of(:psid) }
    end
  end

  describe '#update_from_psid!' do
    before do
      allow(subject).to receive(:profile_details_from_messenger)
        .and_return(SAMPLE_MESSENGER_PROFILE)
    end

    it "updates the fbid if it's not present" do
      subject.fbid = nil
      fbid = SAMPLE_MESSENGER_PROFILE['id']
      expect { subject.update_from_psid! }
        .to change { subject.fbid }.from(nil).to(fbid.to_i)

      subject.update!(fbid: 1234)
      expect { subject.update_from_psid! }.not_to(change { subject.fbid })
    end

    it "updates the email if it's not present" do
      psid = SAMPLE_MESSENGER_PROFILE['id']
      subject.email = nil
      temp_email = "#{psid}#{MessengerProfile::EMAIL_PLACEHOLDER_HOST}"
      expect { subject.update_from_psid! }
        .to change { subject.email }.from(nil).to(temp_email)

      subject.update!(email: 'i-have@email.com')
      expect { subject.update_from_psid! }.not_to(change { subject.email })
    end

    it "updates the name if it's not present" do
      first_name = SAMPLE_MESSENGER_PROFILE['first_name']
      last_name = SAMPLE_MESSENGER_PROFILE['last_name']
      subject.name = nil
      name = "#{first_name} #{last_name}"

      expect { subject.update_from_psid! }
        .to change { subject.name }.from(nil).to(name)

      subject.update!(name: 'i-have-name')
      expect { subject.update_from_psid! }.not_to(change { subject.name })
    end

    it 'always updates the image' do
      image = SAMPLE_MESSENGER_PROFILE['profile_pic']
      subject.image = nil

      expect { subject.update_from_psid! }
        .to change { subject.image }.from(nil).to(image)

      subject.update!(image: 'i-have-image')
      expect { subject.update_from_psid! }
        .to change { subject.image }.from('i-have-image').to(image)
    end

    it "updates the token if it's not present" do
      token = MessengerProfile::TOKEN_PLACEHOLDER
      subject.token = nil

      expect { subject.update_from_psid! }
        .to change { subject.token }.from(nil).to(token)

      subject.update!(token: 'i-have-token')
      expect { subject.update_from_psid! }.not_to(change { subject.token })
    end

    it "updates the expires_at if it's not present" do
      subject.expires_at = nil

      expect { subject.update_from_psid! }
        .to change { subject.expires_at }.from(nil)

      subject.update!(expires_at: 2.days.ago)
      expect { subject.update_from_psid! }.not_to(change { subject.expires_at })
    end
  end

  describe '#first_name' do
    it 'returns the first word before a space' do
      subject.name = 'Johnny Depp'
      expect(subject.first_name).to eq 'Johnny'
    end
  end
end
