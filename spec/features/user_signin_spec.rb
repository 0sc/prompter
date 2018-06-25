require 'rails_helper'
require 'support/omniauth'
require 'support/dummy_facebook_service'

RSpec.describe 'Home page', type: :feature do
  let(:dummy_service) { DummyFacebookService.new }

  before do
    dummy_service.admin_communities = []
    stub_const('FacebookService', dummy_service)
  end

  scenario 'user can sign in' do
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
end
