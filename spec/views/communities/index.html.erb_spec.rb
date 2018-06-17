require 'rails_helper'

RSpec.describe "communities/index", type: :view do
  before(:each) do
    assign(:communities, [
      Community.create!(
        :fbid => "Fbid",
        :name => "Name"
      ),
      Community.create!(
        :fbid => "Fbid",
        :name => "Name"
      )
    ])
  end

  it "renders a list of communities" do
    render
    assert_select "tr>td", :text => "Fbid".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
