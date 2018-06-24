require 'rails_helper'

RSpec.describe 'communities/_subscribed_community', type: :view do
  let(:community) { create(:community).attributes }
  before(:each) { render_partial }

  it 'displays the name of the community with link view details' do
    expect(page).to have_link(
      text: community[:name],
      href: community_path(community['id'])
    )
  end

  it 'displays link to edit community details' do
    expect(page).to have_link(
      text: 'Edit',
      href: edit_community_path(community['id'])
    )
  end

  it 'displays link to unsubscribe the community' do
    expect(page).to have_link(
      text: 'Unsubscribe',
      href: community_path(community['id'])
    )
  end

  def render_partial(opts = {})
    render(
      partial: 'communities/subscribed_community',
      locals: { community: community }.merge(opts)
    )
  end
end
