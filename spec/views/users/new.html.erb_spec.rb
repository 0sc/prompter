require 'spec_helper'

RSpec.describe '/users/new', type: :view do
  it 'displays a link to sign in' do
    render

    expect(page).to have_link(text: 'Sign in', href: '/auth/facebook')
  end
end
