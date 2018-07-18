require 'spec_helper'

RSpec.describe '/users/new', type: :view do
  before { render }

  it 'displays the header' do
    expect(page).to have_content(t('header'))
  end

  it 'displays the subheader' do
    msg = strip_tags(t('subheader_html'))
    expect(page).to have_content(msg)
  end

  it 'displays a link to sign in' do
    expect(page).to have_link(text: t('sign_in'), href: '/auth/facebook')
  end

  def t(key)
    I18n.t(key, scope: %i[users new])
  end
end
