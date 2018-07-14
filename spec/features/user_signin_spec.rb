require 'rails_helper'
require 'support/omniauth'
require 'support/dummy_facebook_service'

RSpec.describe 'Home page', type: :feature do
  let(:dummy_service) { DummyFacebookService.new }

  before do
    dummy_service.admin_communities = []
    stub_const('FacebookService', dummy_service)
  end

  scenario 'user can sign up' do
    visit root_path
    expect(page).to have_link(text: 'Sign in', href: '/auth/facebook')

    expect { click_on('Sign in') }.to change { User.count }.from(0).to(1)

    user = User.first
    expect(user.fbid).to eq SAMPLE_AUTH_HASH[:uid].to_i
    expect(user.email).to eq SAMPLE_AUTH_HASH[:info][:email]
    expect(user.token).to eq SAMPLE_AUTH_HASH[:credentials][:token]

    expect(current_path).to eq communities_path
    expect(page).to have_content('Communities')
  end

  scenario 'user can sign in' do
    user = create(:user, fbid: SAMPLE_AUTH_HASH[:uid])

    visit root_path
    expect(page).to have_link(text: 'Sign in', href: '/auth/facebook')

    expect { click_on('Sign in') }.not_to(change { User.count })

    user.reload
    expect(user.fbid).to eq SAMPLE_AUTH_HASH[:uid].to_i
    expect(user.email).to eq SAMPLE_AUTH_HASH[:info][:email]
    expect(user.token).to eq SAMPLE_AUTH_HASH[:credentials][:token]

    expect(current_path).to eq communities_path
    expect(page).to have_content('Communities')
  end

  scenario 'user can sign out' do
    visit root_path
    expect(page).to have_link(text: 'Sign in', href: '/auth/facebook')
    click_on('Sign in')

    expect(current_path).to eq communities_path
    expect(page).to have_content('Communities')

    expect(page).to have_link(text: 'Sign out', href: logout_users_path)
    click_on('Sign out')
    expect(current_path).to eq root_path
  end

  scenario 'redirects signed in users to community path on root_path visit' do
    visit root_path
    expect(page).to have_link(text: 'Sign in', href: '/auth/facebook')
    click_on('Sign in')

    expect(current_path).to eq communities_path
    expect(page).to have_content('Communities')

    visit root_path
    expect(current_path).to eq communities_path
    expect(page).to have_content('Communities')
  end

  scenario 'redirects signed out users to root path' do
    visit root_path
    expect(page).to have_link(text: 'Sign in', href: '/auth/facebook')
    click_on('Sign in')

    expect(current_path).to eq communities_path
    expect(page).to have_content('Communities')

    click_on('Sign out')
    expect(current_path).to eq root_path

    visit communities_path
    expect(current_path).to eq root_path
  end
end
