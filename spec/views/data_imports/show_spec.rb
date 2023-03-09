require "rails_helper"

RSpec.describe "data_imports/show.html.erb", type: :view do
  it "displays description and links", :admin do
    data_import = create(:data_import, :unprocessed, description: "DA Desc")
    source_file = data_import.source_file
    assign(:source_file, source_file)
    assign(:data_import, data_import)

    render

    expect(rendered).to have_selector("h1", text: "Data Import")
    expect(rendered).to_not have_text("Occupation standard")
    expect(rendered).to have_text("DA Desc")
    expect(rendered).to have_link("Edit data import", href: edit_source_file_data_import_path(source_file, data_import))
    expect(rendered).to have_button("Delete data import")
  end

  it "displays link to occupation standard if it exists" do
    occupation_standard = create(:occupation_standard, title: "Mechanic")
    data_import = create(:data_import, description: "DA Desc", occupation_standard: occupation_standard)
    source_file = data_import.source_file
    assign(:source_file, source_file)
    assign(:data_import, data_import)

    render

    expect(rendered).to have_link("Mechanic", href: occupation_standard_path(occupation_standard))
  end
end
