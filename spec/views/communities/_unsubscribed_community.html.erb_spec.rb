require 'rails_helper'

RSpec.describe 'communities/_unsubscribed_community', type: :view do
  let(:community) { create(:community).attributes }
  before(:each) { render_partial }

  it 'displays the name of the community' do
    expect(page).to have_text(community[:name])
  end

  it 'displays link to subscribe the community' do
    expect(page).to have_link(
      text: 'Subscribe',
      href: edit_community_path(community['id'])
    )
  end

  def render_partial(opts = {})
    render(
      partial: 'communities/unsubscribed_community',
      locals: { community: community }.merge(opts)
    )
  end
end
