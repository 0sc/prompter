require 'rails_helper'
RSpec.describe AnalysisWorker, type: :worker do
  let(:community_one) { create(:community) }
  let(:community_two) { create(:community) }

  let(:msg) { 'A post in a the community. About something at sometime' }
  let(:link) { 'https://link.to/the/post/' }
  let(:category_one) { create(:feed_category, name: 'programming') }
  let(:category_two) { create(:feed_category, name: 'skydiving') }
  let(:dummy) { double }
  let(:attrs) do
    lambda do |psid|
      {
        psid: psid,
        name: community_one.name,
        category: category_one.name,
        feed: msg,
        link: link
      }
    end
  end

  before do
    stub_const('WitService', dummy)
    allow(dummy).to receive(:new).with(msg).and_return(dummy)
    allow(dummy).to receive(:analyse)
    allow(dummy).to receive(:intent_value).and_return(category_one.name)

    community_one.community_type.add_feed_category(category_one)
    community_one.community_type.add_feed_category(category_two)
    community_two.community_type.add_feed_category(category_one)
  end

  it 'returns nil if the community does not exist' do
    AnalysisWorker.perform_async(404, msg, link)

    expect(AnalysisWorker.jobs.size).to eq 1
    expect(AnalysisWorker.jobs.first['args']).to match_array([404, msg, link])

    expect(Notifier).not_to receive(:send_community_feed_notice)

    AnalysisWorker.drain
  end

  # for announcements
  it 'returns nil if the link is not present' do
    AnalysisWorker.perform_async(404, msg, nil)

    expect(AnalysisWorker.jobs.size).to eq 1
    expect(AnalysisWorker.jobs.first['args']).to match_array([404, msg, nil])

    expect(Notifier).not_to receive(:send_community_feed_notice)

    AnalysisWorker.drain
  end

  # for things like shared posts and media posts
  it 'returns nil if the feed is not present' do
    AnalysisWorker.perform_async(404, nil, link)

    expect(AnalysisWorker.jobs.size).to eq 1
    expect(AnalysisWorker.jobs.first['args']).to match_array([404, nil, link])

    expect(Notifier).not_to receive(:send_community_feed_notice)

    AnalysisWorker.drain
  end

  it 'triggers a message for each interested member in the community' do
    AnalysisWorker.perform_async(community_one.fbid, msg, link)

    expect(AnalysisWorker.jobs.size).to eq 1
    expect(AnalysisWorker.jobs.first['args'])
      .to match_array([community_one.fbid, msg, link])

    user_one, user_two, user_three, user_four, user_five = create_list(:user, 5)

    user_one.member_profile.add_community(community_one)
    user_two.member_profile.add_community(community_one)
    user_four.member_profile.add_community(community_one)
    user_five.member_profile.add_community(community_one)
    user_two.member_profile.add_community(community_two)
    user_three.member_profile.add_community(community_two)

    user_five.update!(psid: nil) # no psid
    user_four
      .member_profile.community_member_profiles
      .find_by(community: community_one)
      .unsubscribe_from_feed_category(category_one) # not interested in category

    expect(Notifier).to receive(:send_community_feed_notice)
      .ordered.once.with(attrs.call(user_one.psid))
    expect(Notifier).to receive(:send_community_feed_notice)
      .ordered.once.with(attrs.call(user_two.psid))

    AnalysisWorker.drain
  end
end
