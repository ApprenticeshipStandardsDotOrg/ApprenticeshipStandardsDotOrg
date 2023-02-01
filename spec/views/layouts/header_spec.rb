require "rails_helper"

RSpec.describe "layouts/_header.html.erb", type: :view do
  it "has the expected navigation links" do
    render

    expect(rendered).to have_css "a[href='#{file_imports_path}']", text: "File imports"
    expect(rendered).to have_css "a[href='#{data_imports_path}']", text: "Data imports"
    expect(rendered).to have_css "a[href='#{occupation_standards_path}']", text: "Occupation Standards"
    expect(rendered).to have_css "a[href='#{edit_user_registration_path}']", text: "Edit account"
  end
end
