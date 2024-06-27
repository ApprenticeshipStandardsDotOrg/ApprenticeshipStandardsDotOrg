require "rails_helper"

RSpec.describe "standards_imports/show", type: :view do
  it "displays all files uploaded" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)

    docx_file = file_fixture("document.docx")
    pdf_file1 = file_fixture("pixel1x1.pdf")
    pdf_file2 = file_fixture("pixel1x1_redacted.pdf")

    standards_import = create(:standards_import)
    uncat1 = create(:imports_uncategorized, parent: standards_import, file: docx_file)
    _uncat2 = create(:imports_uncategorized, parent: standards_import, file: pdf_file1)
    create(:imports_pdf, parent: uncat1, file: pdf_file2)

    assign :standards_import, standards_import.reload

    render template: "standards_imports/show", layout: "layouts/application"

    expect(rendered).to have_content "document.docx"
    expect(rendered).to have_content "pixel1x1.pdf"
    expect(rendered).to_not have_content "pixel1x1_redacted.pdf"
  end
end
