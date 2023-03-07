require "rails_helper"

RSpec.describe "data_imports/show.html.erb", type: :view do
  it "displays description and links", :admin do
    data_import = create(:data_import, :unprocessed, description: "DA Desc")
    file_import = data_import.file_import
    assign(:file_import, file_import)
    assign(:data_import, data_import)

    render

    expect(rendered).to have_selector("h1", text: "Data Import")
    expect(rendered).to_not have_text("Occupation standard")
    expect(rendered).to have_text("DA Desc")
    expect(rendered).to have_link("Edit data import", href: edit_file_import_data_import_path(file_import, data_import))
    expect(rendered).to have_button("Delete data import")
  end

  it "displays link to occupation standard if it exists" do
    occupation_standard = create(:occupation_standard, title: "Mechanic")
    data_import = create(:data_import, description: "DA Desc", occupation_standard: occupation_standard)
    file_import = data_import.file_import
    assign(:file_import, file_import)
    assign(:data_import, data_import)

    render

    expect(rendered).to have_link("Mechanic", href: occupation_standard_path(occupation_standard))
  end
end
