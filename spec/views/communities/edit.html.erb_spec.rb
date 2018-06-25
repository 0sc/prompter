require 'rails_helper'

RSpec.describe 'communities/edit', type: :view do
  let(:community) { create(:community) }

  before(:each) do
    assign(:community, community)
    render
  end

  it 'renders the heading' do
    expect(page).to have_content("Editing Community: #{community.name}")
  end

  it 'renders the edit community form' do
    expect(page).to have_selector('form')
  end

  it 'displays link to view community details' do
    expect(page).to have_link(text: 'Show', href: community_path(community))
  end

  it 'displays link to go back to communities path' do
    expect(page).to have_link(text: 'Back', href: communities_path)
  end
end
