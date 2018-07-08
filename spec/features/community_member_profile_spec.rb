require 'rails_helper'
require 'support/omniauth'
require 'support/dummy_facebook_service'

RSpec.describe 'CommunityMemberProfile', type: :feature do
  let(:dummy_service) { DummyFacebookService.new }
  let!(:user) { create(:user, fbid: SAMPLE_AUTH_HASH[:uid]) }
  let(:community) { create(:community, :with_feed_categories, amount: 3) }
  let(:profile) do
    create(:community_member_profile,
           member_profile: user.member_profile,
           community: community)
  end

  before { stub_const('FacebookService', dummy_service) }

  it 'redirects to root path if user is not signed in' do
    visit community_member_profile_path(profile)
    expect(current_path).to eq root_path
  end

  scenario 'user can view their community member profile' do
    sign_in
    visit community_member_profile_path(profile)
    expect(page.find('h1'))
      .to have_content("Subscription Profile for: #{community.name}")
    within 'ul' do
      expect(page.all('li').count).to eq 3
      page.all('li').each_with_index do |li, index|
        expect(li).to have_content community.feed_categories[index].name
      end
    end

    expect(page)
      .to have_link('Edit', href: edit_community_member_profile_path(profile))
  end

  scenario 'user can edit their community member profile' do
    expect(profile.subscribe_to_all_feed_categories).to be true
    expect(profile.feed_categories).to eq community.feed_categories

    sign_in
    visit community_member_profile_path(profile)
    click_on 'Edit'

    expect(current_path).to eq edit_community_member_profile_path(profile)
    expect(page.find('h1')).to have_content 'Edit stuff'

    within 'form' do
      community.feed_categories.each do |feed_category|
        expect(page).to have_field(feed_category.name, checked: true)
      end

      community.feed_categories.first(2).each { |fd| uncheck fd.name }

      click_on 'Update'
    end

    expect(current_path).to eq community_member_profile_path(profile)

    within 'ul' do
      expect(page.all('li').count).to be 1
      expect(page.find('li')).to have_content community.feed_categories[-1].name
    end
    expect(profile.reload.feed_categories).to eq [community.feed_categories[-1]]
  end

  scenario 'user can destroy their community member profile' do
    expect(profile.feed_categories).to eq community.feed_categories

    sign_in
    visit community_member_profile_path(profile)
    click_on 'Edit'

    expect(current_path).to eq edit_community_member_profile_path(profile)
    expect(page.find('h1')).to have_content 'Edit stuff'

    within 'form' do
      community.feed_categories.each do |feed_category|
        expect(page).to have_field(feed_category.name, checked: true)
        uncheck feed_category.name
      end

      expect do
        click_on 'Update'
      end.to change { CommunityMemberProfile.count }.from(1).to(0)
    end

    expect(current_path).to eq curtain_community_member_profiles_path
    expect(page.find('h1')).to have_content('Nothing to see here!')
  end

  def sign_in
    visit root_path
    click_on('Sign in')
  end
end
