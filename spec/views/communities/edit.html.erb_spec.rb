require 'rails_helper'

RSpec.describe 'communities/edit', type: :view do
  let(:community) { create(:community) }

  before(:each) do
    # HACK: definied the helper current_user on the view object
    # rspec does not current provide any way to stub controller defined helpers
    # https://github.com/rspec/rspec-rails/issues/215
    # https://github.com/rspec/rspec-rails/issues/1076
    def view.current_user; end

    assign(:community, community)
    render
  end

  it 'renders the heading' do
    expect(page).to have_content(community.name)
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
