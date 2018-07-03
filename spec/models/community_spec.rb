require 'rails_helper'

RSpec.describe Community, type: :model do
  subject { build(:community) }

  it { should validate_presence_of(:fbid) }
  it { should validate_presence_of(:name) }

  it { should validate_uniqueness_of(:fbid) }

  it { should have_many(:community_admin_profiles) }
  it { should have_many(:community_member_profiles) }
  it { should have_many(:admin_profiles).through(:community_admin_profiles) }
  it { should have_many(:member_profiles).through(:community_member_profiles) }

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
end
