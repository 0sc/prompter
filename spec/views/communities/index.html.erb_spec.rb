require 'rails_helper'

RSpec.describe "communities/index", type: :view do
  before(:each) do
    assign(:communities, create_list(:community, 2))
    assign(:current_user, create(:user))
  end

  xit "renders a list of communities" do
    render
    assert_select "tr>td", :text => "Fbid".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
