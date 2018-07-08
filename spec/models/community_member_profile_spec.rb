require 'rails_helper'

RSpec.describe CommunityMemberProfile, type: :model do
  subject { create(:community_member_profile) }

  it { should belong_to(:community) }
  it { should belong_to(:member_profile) }
  it do
    should have_many(:community_member_profile_feed_categories)
      .dependent(:destroy)
  end
  it do
    should have_many(:feed_categories)
      .through(:community_member_profile_feed_categories)
  end

  it { should validate_presence_of(:community_id) }
  it { should validate_presence_of(:member_profile_id) }
  it { should validate_uniqueness_of(:community_id).scoped_to(:member_profile_id) }

  describe 'after_create callback' do
    it 'subscribes the profile to all the communities feed_categories' do
      community = create(:community, :with_feed_categories, amount: 3)
      subject = build(:community_member_profile, community: community)

      expect(subject.feed_categories).to be_empty

      expect { subject.save }
        .to change { CommunityMemberProfileFeedCategory.count }.from(0).to(3)

      expect(subject.feed_categories).to eq community.feed_categories
    end
  end

  describe '#feed_category?' do
    it 'delegates feed_category? to community' do
      expect(subject.feed_category?('a'))
        .to eq subject.community.feed_category?('a')
    end
  end

  describe '#community_name' do
    it 'delegates community_name as name to community' do
      expect(subject.community_name).to eq subject.community.name
    end
  end

  describe '#subscribe_to_all_feed_categories' do
    it 'subscribes the user to all the communities feed_categories' do
      community = subject.community
      create_feed_categories_for_community(community)

      expect(subject.reload.feed_categories).to be_empty
      subject.subscribe_to_all_feed_categories
      expect(subject.reload.feed_categories)
        .to eq community.reload.feed_categories
    end
  end

  describe '#subscribed_feed_category?' do
    it 'returns true if there are any feed_categories' do
      create_feed_categories_for_community(subject.community)
      subject.update(feed_categories: subject.community.feed_categories)

      expect(subject.subscribed_feed_category?).to be true
    end

    it 'returns false if there are no feed_categories' do
      CommunityMemberProfileFeedCategory
        .where(community_member_profile: subject).map(&:destroy)

      expect(subject.subscribed_feed_category?).to be false
    end
  end

  describe '#subscribe_to_feed_category' do
    let(:feed_category) do
      create_feed_categories_for_community(subject.community).feed_category
    end

    it 'subscribes member_profile to the feed_category' do
      expect(subject.feed_categories).to be_empty
      subject.subscribe_to_feed_category(feed_category)
      expect(subject.reload.feed_categories).to eq [feed_category]
    end

    it 'does not duplicate subscription if already exists' do
      subject.subscribe_to_feed_category(feed_category)
      expect(subject.reload.feed_categories).to eq [feed_category]

      expect { subject.subscribe_to_feed_category(feed_category) }
        .not_to(change { subject.feed_categories.reload })

      expect(subject.reload.feed_categories).to eq [feed_category]
    end

    it 'does not subscribe if feed_category is not in community type' do
      feed_category = create(:feed_category)
      record = subject.subscribe_to_feed_category(feed_category)
      expect(record.persisted?).to be false
      expect(record.valid?).to be false
      expect(record.errors.keys).to eq [:feed_category]
      expect(subject.reload.feed_categories).to be_empty
    end
  end

  describe '#unsubscribe_from_feed_category' do
    let(:feed_category) do
      create_feed_categories_for_community(subject.community).feed_category
    end

    it 'unsubscribes from the given feed_category' do
      subject.subscribe_to_feed_category(feed_category)
      expect(subject.reload.feed_categories).to eq [feed_category]
      subject.unsubscribe_from_feed_category(feed_category)
      expect(subject.reload.feed_categories).to eq []
    end
  end

  describe '#feed_category_summary' do
    context 'less than three feed categories' do
      let(:comm_with_1) { create(:community, :with_feed_categories, amount: 1) }
      let(:comm_with_2) { create(:community, :with_feed_categories, amount: 2) }
      let(:comm_with_3) { create(:community, :with_feed_categories, amount: 3) }

      it 'return the names of the categories' do
        [
          create(:community_member_profile, community: comm_with_1),
          create(:community_member_profile, community: comm_with_2),
          create(:community_member_profile, community: comm_with_3)
        ].each_with_index do |profile, i|
          expect(profile.subscribed_feed_category_summary).to eq(
            send("comm_with_#{i + 1}").feed_categories.map(&:name).to_sentence
          )
        end
      end
    end

    context 'more than three feed categories' do
      let(:comm_2) { create(:community, :with_feed_categories, amount: 4) }
      let(:comm_1) { create(:community, :with_feed_categories, amount: 7) }

      it 'returns the name of the first three and the number renaming' do
        [
          create(:community_member_profile, community: comm_1),
          create(:community_member_profile, community: comm_2)
        ].each_with_index do |profile, i|
          categories = send("comm_#{i + 1}").feed_categories
          msg = (
            categories.first(3).map(&:name) + ["#{categories.size - 3} others"]
          ).to_sentence

          expect(profile.subscribed_feed_category_summary).to eq msg
        end
      end
    end
  end

  def create_feed_categories_for_community(community)
    create(:community_type_feed_category,
           community_type: community.community_type)
      .tap { community.reload }
  end
end
