require 'rails_helper'

RSpec.describe 'communities/_subscribed_community', type: :view do
  let(:db_id) { 1234 }
  let(:community) do
    attributes_for(:community).merge('id' => 'fbid').stringify_keys
  end
  before(:each) { render_partial }

  it 'displays the community icon image' do
    expect(page).to have_selector("img[src='#{community['icon']}']")
  end

  it 'displays the name of the community with link view details' do
    expect(page).to have_link(
      text: community['name'],
      href: community_path(db_id)
    )
  end

  it 'displays link to edit community details' do
    expect(page).to have_link(
      text: t('edit'),
      href: edit_community_path(db_id)
    )
  end

  it 'displays link to unsubscribe the community' do
    expect(page).to have_link(
      text: 'remove_circle',
      href: community_path(db_id)
    )
  end

  def render_partial(opts = {})
    render(
      partial: 'communities/subscribed_community',
      locals: { community: community, id: db_id }.merge(opts)
    )
  end

  def t(key)
    I18n.t(key, scope: %i[communities subscribed_community])
  end
end
