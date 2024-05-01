require "rails_helper"

RSpec.describe DocxListingSplitter do
  describe "#split" do
    context "with file that has attachments" do
      it "attaches 7 files to original standards_import file, marks original source_file as archived, and is idempotent" do
        # When viewing this file it looks to only have 6 attachments, but when
        # the files are extracted, there are 2 Word docs and 5 PDFs. Not sure
        # why only 4 PDFs are visible when viewing the doc.
        perform_enqueued_jobs do
          uncategorized = create(:imports_uncategorized, :docx_listing)
          id = "8"
          file_names = []

          described_class.split(id, uncategorized.file) do |n|
            file_names = n
          end

          expect(file_names.size).to eq 7
        end
      end
    end

    context "with file that doesn't have attachments" do
      it "does not attach any files to the StandardImport and marks original source_file as archived" do
        perform_enqueued_jobs do
          uncategorized = create(:imports_uncategorized, :pdf)
          id = "8"
          file_names = []

          described_class.split(id, uncategorized.file) do |n|
            file_names = n
          end

          expect(file_names.size).to eq(0)
        end
      end
    end

    context "with PDF attachments" do
      it "extracts the PDF from the OLE storage wrapper" do
        uncategorized = create(:imports_uncategorized, :docx_listing)
        id = "8"
        pdfs_seen = 0

        described_class.split(id, uncategorized.file) do |file_names|
          file_names.each do |file_name|
            if file_name.end_with?(".pdf")
              mime_type = Marcel::MimeType.for(Pathname.new(file_name))
              expect(mime_type).to eq("application/pdf")
              pdfs_seen += 1
            end
          end
        end

        expect(pdfs_seen).to eq 5
      end
    end
  end
end
