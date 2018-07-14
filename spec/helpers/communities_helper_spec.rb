require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the CommunitiesHelper. For example:
#
# describe CommunitiesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe CommunitiesHelper, type: :helper do
  describe '#ref_link' do
    it 'returns the ref link to the bot with the given code' do
      stub_const('ENV', 'BOT_URL' => 'm.me/meee')
      link = 'm.me/meee?ref=secret_code'
      expect(helper.ref_link('secret_code')).to eq link
    end
  end
end
