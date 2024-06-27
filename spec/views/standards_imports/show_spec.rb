require "rails_helper"

RSpec.describe "standards_imports/show", type: :view do
  context "with imports feature flag off" do
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

  context "with imports feature flag on" do
    it "displays all files uploaded" do
      stub_feature_flag(:show_imports_in_administrate, true)

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

      stub_feature_flag(:show_imports_in_administrate, false)
    end
  end
end
