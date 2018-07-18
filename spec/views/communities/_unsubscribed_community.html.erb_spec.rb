require 'rails_helper'

RSpec.describe 'communities/_unsubscribed_community', type: :view do
  let(:community) { create(:community).attributes }
  before(:each) { render_partial }

  it 'displays the community icon image' do
    expect(page).to have_selector("img[src='#{community['icon']}']")
  end

  it 'displays the name of the community' do
    expect(page).to have_text(community[:name])
  end

  it 'displays link to subscribe the community' do
    expect(page).to have_link(
      text: t('subscribe'),
      href: communities_path(fbid: community['id'])
    )
  end

  def render_partial(opts = {})
    render(
      partial: 'communities/unsubscribed_community',
      locals: { community: community }.merge(opts)
    )
  end

  def t(key)
    I18n.t(key, scope: %i[communities unsubscribed_community])
  end
end
