require 'rails_helper'

RSpec.describe 'communities/index', type: :view do
  let(:community_one) do
    { 'id' => 1, 'name' => 'name one', 'icon' => 'https://icon-image-url.png' }
  end
  let(:community_two) do
    { 'id' => 2, 'name' => 'name two', 'icon' => 'https://icon-image-url.png' }
  end

  before do
    # HACK: definied the helper current_user on the view object
    # rspec does not current provide any way to stub controller defined helpers
    # https://github.com/rspec/rspec-rails/issues/215
    # https://github.com/rspec/rspec-rails/issues/1076
    def view.current_user; end

    assign(:fb_communities, [community_one, community_two])
    assign(:subscribed_communities_mapping, [{ 'fbid' => 1 }])
  end

  it 'displays the heading' do
    render

    expect(page.find('h1.header')).to have_content('Communities')
  end

  it 'renders a list of communities' do
    render

    expect(page).to have_css('h1', text: 'Communities')
    expect(page.find('.section ul').all('li').count).to eq 2
  end
end
