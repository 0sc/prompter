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
    expect(page).to have_link(text: users_t('new.sign_in'),
                              href: '/auth/facebook')
    expect { click_link(users_t('new.sign_in')) }
      .to change { User.count }.from(0).to(1)

    user = User.first
    expect(user.fbid).to eq SAMPLE_AUTH_HASH[:uid].to_i
    expect(user.email).to eq SAMPLE_AUTH_HASH[:info][:email]
    expect(user.token).to eq SAMPLE_AUTH_HASH[:credentials][:token]

    expect(current_path).to eq communities_path
    expect(page).to have_content(t('title', 'communities.index'))
  end

  scenario 'user can sign in' do
    user = create(:user, email: SAMPLE_AUTH_HASH[:info][:email])

    visit root_path
    expect(page).to have_link(text: users_t('new.sign_in'),
                              href: '/auth/facebook')

    expect { click_link(users_t('new.sign_in')) }.not_to(change { User.count })

    user.reload
    expect(user.fbid).to eq SAMPLE_AUTH_HASH[:uid].to_i
    expect(user.email).to eq SAMPLE_AUTH_HASH[:info][:email]
    expect(user.token).to eq SAMPLE_AUTH_HASH[:credentials][:token]

    expect(current_path).to eq communities_path
    expect(page).to have_content(t('title', 'communities.index'))
  end

  scenario 'user can sign out' do
    visit root_path
    expect(page).to have_link(text: users_t('new.sign_in'),
                              href: '/auth/facebook')
    click_link(users_t('new.sign_in'))

    expect(current_path).to eq communities_path
    expect(page).to have_content(t('title', 'communities.index'))

    expect(page).to have_link(text: t('sign_out', 'layouts.navbar'),
                              href: logout_users_path)
    click_link(t('sign_out', 'layouts.navbar'))
    expect(current_path).to eq root_path
  end

  scenario 'redirects signed in users to community path on root_path visit' do
    visit root_path
    expect(page).to have_link(text: users_t('new.sign_in'),
                              href: '/auth/facebook')
    click_link(users_t('new.sign_in'))

    expect(current_path).to eq communities_path
    expect(page).to have_content(t('title', 'communities.index'))

    visit root_path
    expect(current_path).to eq communities_path
    expect(page).to have_content(t('title', 'communities.index'))
  end

  scenario 'redirects signed out users to root path' do
    visit root_path
    expect(page).to have_link(text: users_t('new.sign_in'),
                              href: '/auth/facebook')
    click_link(users_t('new.sign_in'))

    expect(current_path).to eq communities_path
    expect(page).to have_content(t('title', 'communities.index'))

    click_link(t('sign_out', 'layouts.navbar'))
    expect(current_path).to eq root_path

    visit communities_path
    expect(current_path).to eq root_path
  end

  def users_t(key)
    t(key, %i[users])
  end

  def t(key, scope)
    I18n.t(key, scope: scope)
  end
end
