require 'rails_helper'

RSpec.describe 'community_member_profiles/curtain', type: :view do
  before { render }

  it 'displays the nothing to see here heading' do
    expect(page.find('h1')).to have_content(t('header'))
  end

  it 'displays a link to the root path' do
    expect(page).to have_link(t('home'), href: root_path)
  end

  def t(key)
    I18n.t(key, scope: %i[community_member_profiles curtain])
  end
end
