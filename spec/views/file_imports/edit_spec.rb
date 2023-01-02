require "rails_helper"

RSpec.describe "file_imports/edit.html.erb", type: :view do
  it "has heading text" do
    assign(:file_import, build(:file_import))
    allow(view).to receive(:current_user).and_return(build(:admin))
    render

    expect(rendered).to have_link("Edit", exact: true)
  end
end
