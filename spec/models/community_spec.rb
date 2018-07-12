require 'rails_helper'

RSpec.describe Community, type: :model do
  subject { build(:community) }

  it { should validate_presence_of(:fbid) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:fbid).case_insensitive }

  it { should belong_to(:community_type).optional }
  it { should have_many(:community_admin_profiles).dependent(:destroy) }
  it { should have_many(:community_member_profiles).dependent(:destroy) }
  it { should have_many(:admin_profiles).through(:community_admin_profiles) }
  it { should have_many(:member_profiles).through(:community_member_profiles) }

  describe '.before_validation' do
    context 'referral_code' do
      it 'sets a referral_code' do
        subject.referral_code = nil
        expect(subject.valid?).to be true
        expect(subject.referral_code).not_to be nil

        expect(subject.save).to be true
      end

      it 'overwrites any existing referral_code' do
        subject.referral_code = 'something custom'
        expect(subject.valid?).to be true
        expect(subject.referral_code).not_to be 'something custom'

        expect(subject.save).to be true
      end
    end
  end

  describe 'update_from_fb_graph!' do
    it 'update the community name, cover and icon' do
      graph = {
        'name' => 'Another one',
        'icon' => 'mini-awesome.jpg',
        'cover' => { 'source' => 'cover-image-source.png' }
      }

      old_attrs = subject.attributes
      subject.update_from_fb_graph!(graph)
      subject.reload

      %w[name icon].each do |field|
        expect(subject[field]).not_to eq old_attrs[field]
        expect(subject[field]).to eq graph[field]
      end

      expect(subject['cover']).not_to eq old_attrs['cover']
      expect(subject['cover']).to eq graph.dig('cover', 'source')
    end
  end

  describe '.subscribable' do
    it 'returns only communities that have community_type set' do
      community = create(:community)
      create(:community, community_type: nil)

      expect(Community.count).to be 2
      expect(Community.subscribable).to eq [community]
    end
  end

  describe '#subscribable?' do
    let(:community) { create(:community) }

    it 'returns true if community has community_type set' do
      expect(community.subscribable?).to be true
    end

    it 'returns false if community does not have community type set' do
      community.update!(community_type: nil)
      expect(community.subscribable?).to be false
    end
  end

  describe '#subscribers?' do
    let(:community) { create(:community) }

    it 'returns true if community has member_profiles' do
      create(:community_member_profile, community: community)
      expect(community.subscribers?).to be true
    end

    it 'returns false if community does not have member_profiles' do
      CommunityMemberProfile.where(community: community).map(&:destroy)

      community.update!(community_type: nil)
      expect(community.subscribers?).to be false
    end
  end

  describe '#community_type_name' do
    it 'returns the name of the community type' do
      community_one = create(:community, community_type: nil)
      community_two = create(:community)

      expect(community_one.community_type_name).to be nil
      expect(community_two.community_type_name)
        .to eq community_two.community_type.name
    end
  end

  describe '#feed_category?' do
    it 'returns an empty array if community type is not set' do
      subject.update!(community_type: nil)
      expect(subject.feed_category?('a')).to be false
    end

    it 'return the community type feed_categories' do
      expect(subject.feed_categories)
        .to eq subject.community_type.feed_categories
    end
  end

  describe '#feed_categories' do
    it 'returns an empty array if community type is not set' do
      subject.update!(community_type: nil)
      expect(subject.feed_categories).to eq []
    end

    it 'return the community type feed_categories' do
      expect(subject.feed_categories)
        .to eq subject.community_type.feed_categories
    end
  end
end
