require 'rails_helper'

RSpec.describe CommunityType, type: :model do
  subject { create(:community_type) }
  let(:feed_category) { create(:feed_category) }

  it { should have_many(:communities).dependent(:nullify) }
  it { should have_many(:community_type_feed_categories).dependent(:destroy) }
  it do
    should have_many(:feed_categories).through(:community_type_feed_categories)
  end

  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }

  describe '#add_feed_category' do
    context 'subject already has feed_category' do
      it "doesn't double add the feed_category" do
        subject.feed_categories << feed_category

        expect { subject.add_feed_category(feed_category) }
          .not_to(change { subject.feed_categories.count })
        expect(subject.feed_categories).to eq [feed_category]
      end
    end

    context "subject doesn't have feed_category" do
      it 'adds the feed_category' do
        expect { subject.add_feed_category(feed_category) }
          .to(change { subject.feed_categories.count }.from(0).to(1))

        expect(subject.feed_categories).to eq [feed_category]
      end
    end
  end

  describe '#remove_feed_category' do
    before { subject.feed_categories << feed_category }

    it 'removes the feed_category from the member_profile' do
      expect { subject.remove_feed_category(feed_category) }
        .to change { subject.feed_categories.count }.from(1).to(0)
    end
  end

  describe '#feed_category?' do
    let(:feed_category_one) { create(:feed_category) }
    let(:feed_category_two) { create(:feed_category) }
    before { subject.feed_categories << feed_category_one }

    it 'returns true if the feed_category exists for the community type' do
      expect(subject.feed_category?(feed_category_one)).to be true
    end

    it 'returns false if the feed_category does not exist for the com type' do
      expect(subject.feed_category?(feed_category_two)).to be false
    end
  end
end
