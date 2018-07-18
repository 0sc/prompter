require 'rails_helper'

RSpec.describe 'communities/show', type: :view do
  let(:community) { create(:community) }

  before(:each) do
    # HACK: definied the helper current_user on the view object
    # rspec does not current provide any way to stub controller defined helpers
    # https://github.com/rspec/rspec-rails/issues/215
    # https://github.com/rspec/rspec-rails/issues/1076
    def view.current_user; end

    def view.facebook_key; end

    def view.facebook_page_id; end

    assign(:community, community)
    stub_const('ENV', 'BOT_URL' => 'm.me/meee')
    render
  end

  it 'displays the nav bar' do
    expect(page).to have_selector('nav')
  end

  it 'displays the community cover image' do
    expect(page).to have_selector("img[src='#{community.cover}']")
  end

  it 'displays the community name' do
    expect(page).to have_content(community.name)
  end

  it 'displays the community type name' do
    expect(page).to have_content(community.community_type_name.titleize)
  end

  it 'displays the number of subscribed member profiles' do
    expect(page).to have_content(community.member_profiles.count)
  end

  it 'displays link with referral_code' do
    link = 'm.me/meee?ref=' + community.referral_code
    expect(page).to have_content(link)
  end

  it 'displays the qrcode' do
    expect(page).to have_selector("img[src='#{community.qrcode}']")
  end

  it 'displays link to edit the community details' do
    expect(page)
      .to have_link(text: t('cta.edit'), href: edit_community_path(community))
  end

  it 'displays link to go back to communities path' do
    expect(page).to have_link(text: t('cta.back'), href: communities_path)
  end

  it 'displays the message button' do
    expect(page).to have_selector('div.fb-messengermessageus')
  end

  def t(key)
    I18n.t(key, scope: %i[communities show])
  end
end
