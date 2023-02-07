require "rails_helper"

RSpec.describe "data_imports/index.html.erb", type: :view do
  it "displays description and edit link", :admin do
    data_import = create(:data_import, description: "DA Desc")
    assign(:data_imports, DataImport.all)

    render

    expect(rendered).to have_selector("h1", text: "Occupation Standard Data Import")
    expect(rendered).to have_link("DA Desc", href: data_import_path(data_import))
    expect(rendered).to have_link("Edit", href: edit_data_import_path(data_import))
    expect(rendered).to have_link("Upload data import", href: new_data_import_path)
  end
end
