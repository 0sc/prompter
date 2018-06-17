require 'rails_helper'

RSpec.describe "communities/show", type: :view do
  before(:each) do
    @community = assign(:community, Community.create!(
      :fbid => "Fbid",
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Fbid/)
    expect(rendered).to match(/Name/)
  end
end
