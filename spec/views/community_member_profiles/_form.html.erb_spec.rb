require 'rails_helper'

RSpec.describe 'community_member_profiles/_form', type: :view do
  let(:community) { create(:community, :with_feed_categories, amount: 5) }
  subject { create(:community_member_profile, community: community) }

  describe '#errors' do
    context 'submission errors exists' do
      it 'displays the error' do
        atrs = CommunityMemberProfile.new.attributes.except 'id', 'community_id'
        subject.attributes = atrs

        expect(subject.valid?).to be false

        render_partial(profile: subject)

        expect(page).to have_css('#error_explanation')
        scoped = page.find('#error_explanation')

        subject.errors.full_messages.each do |msg|
          expect(scoped).to have_content(msg)
        end
      end
    end

    context 'no submission error exists' do
      it 'does not display any errors' do
        render_partial(profile: subject)

        expect(page).not_to have_css('#error_explanation')
      end
    end
  end

  describe 'feed_category_ids' do
    it 'displays a checkbox for all the community feed category' do
      render_partial

      community.feed_categories.each do |feed_category|
        expect(page).to have_field(feed_category.name)
      end
    end
  end

  describe 'warning' do
    it 'displays a warning on deleteting of subscription if all unchecked' do
      render_partial
      msg = 'Deselecting all categories will automatically ' \
            'unsubcribe you from this community'
      expect(page).to have_content(msg)
    end
  end

  def render_partial(opts = {})
    render(
      partial: 'community_member_profiles/form',
      locals: { profile: subject }.merge(opts)
    )
  end
end
