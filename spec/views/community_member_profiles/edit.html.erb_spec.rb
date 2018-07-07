require 'rails_helper'

RSpec.describe 'community_member_profiles/edit', type: :view do
  subject { create(:community_member_profile) }

  before(:each) do
    assign(:community_member_profile, subject)
    render
  end

  it 'renders the heading' do
    expect(page).to have_content('Edit stuff')
  end

  it 'renders the edit community member profile form' do
    expect(page).to have_selector('form')
  end

  it 'displays link to go back to communities member profile page' do
    expect(page).to have_link(
      text: 'Back',
      href: community_member_profile_path(subject)
    )
  end
end
