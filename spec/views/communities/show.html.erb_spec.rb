require 'rails_helper'

RSpec.describe "communities/show", type: :view do
  let(:community) { create(:community) }

  before(:each) do
    assign(:community, community)
    render
  end

  it 'displays the Fbid' do
    expect(page).to have_content(community.fbid)
  end

  it 'displays the community name' do
    expect(page).to have_content(community.name)
  end

  it 'displays link to edit the community details' do
    expect(page).to have_link(text: 'Edit', href: edit_community_path(community))
  end

  it 'displays link to go back to communities path' do
    expect(page).to have_link(text: 'Back', href: communities_path)
  end
end
