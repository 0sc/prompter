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

  describe 'community_type field' do
    it 'displays drop down to select community type' do
      render_partial(community: community)
      expect(page).to have_css("select[name='community[community_type_id]']")
    end

    context 'existing subscribers' do
      before(:each) { create(:community_member_profile, community: community) }

      it 'displays warning' do
        render_partial(community: community)

        expect(page).to have_content(
          'Warning! changing this will reset all existing member subscriptions'
        )
      end
    end

    context 'there are no existing subscribers' do
      before(:each) do
        CommunityMemberProfile.where(community: community).map(&:destroy)
      end

      it 'does not display any warning' do
        render_partial(community: community)

        expect(page).not_to have_text(
          'Warning! changing this will reset all existing member subscriptions'
        )
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
