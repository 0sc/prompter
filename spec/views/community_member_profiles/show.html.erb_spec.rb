require 'rails_helper'

RSpec.describe 'community_member_profiles/show', type: :view do
  let(:community) { create(:community, :with_feed_categories, amount: 2) }

  subject { create(:community_member_profile, community: community) }
  before(:each) do
    community.feed_categories.each do |feed_category|
      subject.subscribe_to_feed_category(feed_category)
    end

    assign(:community_member_profile, subject)
    assign(:community, community)
  end

  it 'displays the community cover image' do
    render
    expect(page).to have_selector("img[src='#{community.cover}']")
  end

  it 'displays the heading' do
    render
    expect(page.find('.card-title')).to have_content community.name
  end

  it 'displays list of categories user is subscribed to' do
    render
    scoped = page.all('li')
    expect(scoped.count).to eq subject.feed_categories.count

    scoped.each_with_index do |li, index|
      expect(li).to have_content(subject.feed_categories[index].name)
    end
  end

  it 'displays link to edit member profile' do
    render
    expect(page).to have_link(
      'Edit',
      href: edit_community_member_profile_path(subject)
    )
  end
end
