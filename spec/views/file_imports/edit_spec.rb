require "rails_helper"

RSpec.describe "file_imports/edit.html.erb", type: :view do
  it "has heading text and form" do
    file_import = create(:file_import)
    assign(:file_import, file_import)

    render

    expect(rendered).to have_selector("h1", text: "Edit #{file_import.filename}")
    expect(rendered).to have_field("Status")
    expect(rendered).to have_field("Metadata", readonly: true, disabled: true)
    expect(rendered).to have_button("Update")
  end
end
