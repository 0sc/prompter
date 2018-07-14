require 'rails_helper'

RSpec.describe 'layouts/_navbar', type: :view do
  before { def view.current_user; end }

  it 'displays link to the home page' do
    render_partial
    expect(page).to have_link(text: 'Home', href: root_path)
  end

  context 'current_user is present' do
    before do
      def view.current_user;
        true
      end
    end

    it 'displays link to sign out' do
      render_partial
      expect(page).to have_link(text: 'Sign out', href: logout_users_path)
    end
  end

  context 'current_user is not present' do
    before { def view.current_user; end }

    it 'displays link to sign in' do
      render_partial
      expect(page).to have_link(text: 'Sign in', href: '/auth/facebook')
    end
  end

  def render_partial
    render partial: 'layouts/navbar'
  end
end
