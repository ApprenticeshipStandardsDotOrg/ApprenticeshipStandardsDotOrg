require "rails_helper"

RSpec.describe "standards_imports/show", type: :view do
  it "does not display files that are linked to an original file" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)

    # Simulate a guest user uploading a docx file that gets converted to a pdf
    # by the time they are shown the standards_imports/show page. We do not want
    # to display the converted pdf file to them.
    perform_enqueued_jobs do
      docx_file = file_fixture("document.docx")
      import = create(:standards_import, files: [docx_file])

      assign :standards_import, import.reload

      render template: "standards_imports/show", layout: "layouts/application"

      expect(rendered).to have_content "document.docx"
      expect(rendered).to_not have_content "document.pdf"
    end
  end
end
