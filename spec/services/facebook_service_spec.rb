require 'rails_helper'

RSpec.describe FacebookService, type: :service do
  let(:subject) { FacebookService.new('user-fbid', 'xyz') }

  describe '#admin_communities' do
    before(:each) do
      allow(subject).to receive(:communities) { dummy_communities }
    end

    it 'returns only communities with administrator set to true' do
      expect(subject.admin_communities).to eq [dummy_communities.second]
    end
  end

  describe '#admin_communities_fbids' do
    it 'returns the fbids of all admin communities' do

    end
  end

  def dummy_communities
    [{ 'id' => 12_345, 'administrator' => false, 'name' => 'community_one' },
     { 'id' => 567_89, 'administrator' => true, 'name' => 'community_two' }]
  end
end
