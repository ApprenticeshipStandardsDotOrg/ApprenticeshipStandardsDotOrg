require "rails_helper"

RSpec.describe "admin/source_files/edit.html.erb", type: :view do
  it "has heading text and form" do
    source_file = create(:source_file)
    assign(:source_file, source_file)

    render

    expect(rendered).to have_selector("h1", text: "Edit #{source_file.filename}")
    expect(rendered).to have_field("Status")
    expect(rendered).to have_field("Metadata", readonly: true, disabled: true)
    expect(rendered).to have_button("Update")
  end
end
