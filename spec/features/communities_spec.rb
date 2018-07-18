require 'rails_helper'
require 'support/omniauth'
require 'support/dummy_facebook_service'

RSpec.describe 'Communities', type: :feature do
  let!(:user) { create(:user, fbid: SAMPLE_AUTH_HASH[:uid]) }
  let(:dummy_service) { DummyFacebookService.new }

  before { stub_const('FacebookService', dummy_service) }

  it 'redirects to root path if user is not signed in' do
    visit communities_path
    expect(current_path).to eq root_path
  end

  scenario 'user can view all their admin communities and their status' do
    subbed = create(:community, name: 'subbed community')
    user.admin_profile.add_community(subbed)
    unsubbed = create(:community, name: 'unsubbed community')
    neww = build(:community, name: 'new community')

    dummy_service.admin_communities = [
      subbed.attributes.merge('id' => subbed.fbid),
      unsubbed.attributes.merge('id' => unsubbed.fbid),
      neww.attributes.merge('id' => neww.fbid)
    ]

    sign_in

    visit communities_path
    expect(page.find('h1')).to have_content(t('index.title'))

    within('.section ul') do
      communities = page.all('li')
      expect(communities.count).to eq 3

      within(communities.first) do
        expect(page)
          .to have_link(text: subbed.name, href: community_path(subbed.id))
        expect(page).to have_link(text: t('subscribed_community.edit'),
                                  href: edit_community_path(subbed.id))
        expect(page)
          .to have_link(text: 'remove_circle', href: community_path(subbed.id))
      end

      within(communities[1]) do
        expect(page).to have_content(subbed.name)
        expect(page).to have_link(
          text: 'add_circle', href: communities_path(fbid: unsubbed.fbid)
        )
      end

      within(communities[2]) do
        expect(page).to have_content(neww.name)
        expect(page).to(
          have_link(text: 'add_circle', href: communities_path(fbid: neww.fbid))
        )
      end
    end
  end

  scenario 'user can subscribe a new community' do
    community = build(:community)
    dummy_service.admin_communities = [community.attributes.merge(
      'id' => community.fbid,
      'cover' => { 'source' => 'http://image.com' }
    )]

    sign_in
    visit communities_path

    within('.section ul') do
      expect(page.all('li').count).to eq 1

      within('li') do
        expect { click_on('add_circle') }
          .to change { Community.count }.from(0).to(1)

        comm = Community.first
        expect(comm.name).to eq community.name
        expect(comm.fbid).to eq community.fbid
        expect(comm.admin_profiles).to include user.admin_profile
        expect(user.admin_profile_communities).to include comm
      end
    end

    community = Community.first
    expect(current_path).to eq edit_community_path(community.id)
    expect(page.find('h1')).to have_content(community.name)

    click_button('Update Community')
    expect(current_path).to eq community_path(community.id)
    expect(page).to have_content(community.name)
  end

  scenario 'user can unsubscribe an existing community' do
    community = create(:community)
    user.admin_profile.add_community(community)

    dummy_service.admin_communities = [
      community.attributes.merge('id' => community.fbid)
    ]

    sign_in
    visit communities_path

    within('.section ul') do
      expect(page.all('li').count).to eq 1

      within('li') do
        expect { click_on('remove_circle') }
          .to change { Community.count }.from(1).to(0)
        expect(user.reload.admin_profile_communities).to be_empty
      end
    end

    expect(current_path).to eq communities_path
    msg = t('destroy.success', name: community.name)
    expect(page.find('#notice')).to have_content(msg)

    within('.section ul') do
      expect(page.all('li').count).to eq 1

      within('li') do
        expect(page).to have_link(text: t('unsubscribed_community.subscribe'),
                                  href: communities_path(fbid: community.fbid))
      end
    end
  end

  scenario 'subscribing a none existent community returns an error notice' do
    community = create(:community)
    dummy_service.admin_communities = [
      community.attributes.merge('id' => community.fbid)
    ]

    sign_in
    visit communities_path

    within('.section ul') do
      expect(page.all('li').count).to eq 1
      dummy_service.admin_communities = []

      within('li') do
        expect { click_on(t('unsubscribed_community.subscribe')) }
          .not_to(change { Community.count })
      end
    end

    expect(current_path).to eq communities_path
    expect(page.find('#notice')).to have_content(t('not_found'))
  end

  scenario 'user can edit a subscribed community' do
    community = create(:community, community_type: nil)
    user.admin_profile_communities << community
    community_type = create(:community_type)

    dummy_service.admin_communities = [
      community.attributes.merge('id' => community.fbid, 'cover' => {})
    ]

    sign_in
    visit communities_path

    within('.section ul') do
      expect(page.all('li').count).to eq 1
      within('li') { click_on('Edit') }
    end

    expect(current_path).to eq edit_community_path(community)
    expect(page.find('h1')).to have_content community.name

    select community_type.name, from: 'community[community_type_id]'
    click_on 'Update Community'

    expect(community.reload.community_type).to eq community_type
    expect(current_path).to eq community_path(community)
    expect(page).to have_content t('update.success')
    expect(page).to have_content community_type.name.titleize
  end

  def sign_in
    visit root_path
    click_on('Sign in')
  end

  def t(key, opts = {})
    I18n.t(key, opts.merge(scope: :communities))
  end
end
