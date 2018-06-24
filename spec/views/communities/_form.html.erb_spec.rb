require 'rails_helper'

RSpec.describe 'communities/form', type: :view do
  let(:community) { create(:community) }

  describe '#errors' do
    context 'submission errors exists' do
      it 'displays the error' do
        community = Community.new
        expect(community.valid?).to be false

        render_partial(community: community)

        expect(page).to have_css('#error_explanation')
        scoped = page.find('#error_explanation')

        community.errors.full_messages.each do |msg|
          expect(scoped).to have_content(msg)
        end
      end
    end

    context 'no submission error exists' do
      it 'does not display any errors' do
        render_partial(community: community)

        expect(page).not_to have_css('#error_explanation')
      end
    end
  end

  def render_partial(opts = {})
    render(
      partial: 'communities/form',
      locals: { community: community }.merge(opts)
    )
  end
end
