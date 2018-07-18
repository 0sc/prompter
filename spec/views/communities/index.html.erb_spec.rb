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

    expect(page.find('h1.header')).to have_content(t('title'))
  end
  context 'user has not admin communities' do
    it 'displays a note to come back later' do
      assign(:fb_communities, [])

      render

      expect(page).to have_css('h1', text: t('title'))
      expect(page).to have_text(t('no_admin_communities'))
      expect(page).not_to have_selector('.section.ul')
    end
  end

  context 'user has admin communities' do
    it 'renders a list of communities' do
      render

      expect(page).to have_css('h1', text: t('title'))
      expect(page.find('.section ul').all('li').count).to eq 2
    end
  end

  def t(key)
    I18n.t(key, scope: %i[communities index])
  end
end
