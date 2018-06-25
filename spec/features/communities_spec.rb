require 'rails_helper'
require 'support/omniauth'
require 'support/dummy_facebook_service'

RSpec.describe 'Communities', type: :feature do
  let!(:user) { create(:user, fbid: SAMPLE_AUTH_HASH[:uid]) }
  let(:dummy_service) { DummyFacebookService.new }

  before do
    stub_const('FacebookService', dummy_service)
    sign_in
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

    visit communities_path
    expect(page.find('h1')).to have_content('Communities')

    within('tbody') do
      communities = page.all('tr')
      expect(communities.count).to eq 3

      within(communities.first) do
        expect(page)
          .to have_link(text: subbed.name, href: community_path(subbed.id))
        expect(page)
          .to have_link(text: 'Edit', href: edit_community_path(subbed.fbid))
        expect(page)
          .to have_link(text: 'Unsubscribe', href: community_path(subbed.id))
      end

      within(communities[1]) do
        expect(page).to have_content(subbed.name)
        expect(page).to(
          have_link(text: 'Subscribe', href: communities_path(fbid: unsubbed.fbid))
        )
      end

      within(communities[2]) do
        expect(page).to have_content(neww.name)
        expect(page).to(
          have_link(text: 'Subscribe', href: communities_path(fbid: neww.fbid))
        )
      end
    end
  end

  scenario 'user can subscribe a new community' do
    community = build(:community)
    dummy_service.admin_communities = [
      community.attributes.merge('id' => community.fbid)
    ]

    visit communities_path

    within('tbody') do
      expect(page.all('tr').count).to eq 1

      within('tr') do
        expect { click_on('Subscribe') }
          .to change { Community.count }.from(0).to(1)

        comm = Community.first
        expect(comm.name).to eq community.name
        expect(comm.fbid).to eq community.fbid
        expect(comm.admin_profiles).to include user.admin_profile
        expect(user.admin_communities).to include comm
      end
    end

    community = Community.first
    expect(current_path).to eq edit_community_path(community.id)
    expect(page.find('h1'))
      .to have_content("Editing Community: #{community.name}")

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

    visit communities_path

    within('tbody') do
      expect(page.all('tr').count).to eq 1

      within('tr') do
        expect { click_on('Unsubscribe') }
          .to change { Community.count }.from(1).to(0)
        expect(user.reload.admin_communities).to be_empty
      end
    end

    expect(current_path).to eq communities_path
    msg = "Your '#{community.name}' community subscription has been removed"
    expect(page.find('#notice')).to have_content(msg)

    within('tbody') do
      expect(page.all('tr').count).to eq 1

      within('tr') do
        expect(page).to(
          have_link(text: 'Subscribe', href: communities_path(fbid: community.fbid))
        )
      end
    end
  end

  scenario 'subscribing a none existent community returns an error notice' do
    community = create(:community)
    dummy_service.admin_communities = [
      community.attributes.merge('id' => community.fbid)
    ]

    visit communities_path

    within('tbody') do
      expect(page.all('tr').count).to eq 1
      dummy_service.admin_communities = []

      within('tr') do
        expect { click_on('Subscribe') }.not_to(change { Community.count })
      end
    end

    expect(current_path).to eq communities_path
    expect(page.find('#notice')).to have_content('Community not found')
  end

  def sign_in
    visit root_path
    click_on('Sign in')
  end
end
