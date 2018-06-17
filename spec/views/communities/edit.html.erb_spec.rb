require 'rails_helper'

RSpec.describe "communities/edit", type: :view do
  before(:each) do
    @community = assign(:community, Community.create!(
      :fbid => "MyString",
      :name => "MyString"
    ))
  end

  it "renders the edit community form" do
    render

    assert_select "form[action=?][method=?]", community_path(@community), "post" do

      assert_select "input[name=?]", "community[fbid]"

      assert_select "input[name=?]", "community[name]"
    end
  end
end
