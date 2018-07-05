require 'rails_helper'

RSpec.describe 'communities/index', type: :view do
  let(:community_one) do
    { 'id' => 1, 'name' => 'name one', 'icon' => 'https://icon-image-url.png' }
  end
  let(:community_two) do
    { 'id' => 2, 'name' => 'name two', 'icon' => 'https://icon-image-url.png' }
  end

  before(:each) do
    assign(:fb_communities, [community_one, community_two])
    assign(:subscribed_communities_mapping, [{ 'fbid' => 1 }])
  end

  it 'renders a list of communities' do
    render

    expect(page).to have_css('h1', text: 'Communities')
    expect(page.find('tbody').all('tr').count).to eq 2
  end
end
