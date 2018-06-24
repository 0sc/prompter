require 'rails_helper'

RSpec.describe 'communities/index', type: :view do
  let(:community_one) { create(:community) }
  let(:community_two) { create(:community) }

  before(:each) do
    assign(:fb_communities, [community_one, community_two])
    assign(:managed_communities, [community_two])
  end

  it 'renders a list of communities' do
    render

    expect(page).to have_css('h1', text: 'Communities')
    expect(page.find('tbody').all('tr').count).to eq 2
  end
end
