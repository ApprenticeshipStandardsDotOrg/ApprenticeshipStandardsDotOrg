require "rails_helper"

RSpec.describe "occupation_standards/show", type: :view do
  it "when public document, it has link to original document" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    allow(ActiveStorage::Current).to receive(:url_options).and_return(host: "https://www.example.com")

    standards_import = create(:standards_import, public_document: true)
    uncat = create(:imports_uncategorized, parent: standards_import)
    pdf = create(:imports_pdf, parent: uncat)
    occupation_standard = create(:occupation_standard)
    create(:data_import, import: pdf, occupation_standard: occupation_standard)

    assign :occupation_standard, occupation_standard

    render

    expect(rendered).to have_text "View Original Document"
  end
end
