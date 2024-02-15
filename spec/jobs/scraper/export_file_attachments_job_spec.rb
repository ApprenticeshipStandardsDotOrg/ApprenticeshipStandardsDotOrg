require "rails_helper"

RSpec.describe Scraper::ExportFileAttachmentsJob do
  describe "#perform" do
    context "with file that has attachments" do
      it "attaches 7 files to original standards_import file and marks original source_file as archived" do
        # When viewing this file it looks to only have 6 attachments, but when
        # the files are extracted, there are 2 Word docs and 5 PDFs. Not sure
        # why only 4 PDFs are visible when viewing the doc.
        standards_import = create(:standards_import, :with_docx_file_with_attachments)
        source_file = SourceFile.last

        perform_enqueued_jobs do
          allow(DocToPdfConverter).to receive(:convert).and_return(nil)
          expect { described_class.new.perform(source_file) }
            .to change { StandardsImport.count }.by(0)
          expect(standards_import.files.count).to eq 8
          expect(source_file.reload).to be_archived
        end
      end
    end

    context "with file that doesn't have attachments" do
      it "does not attach any files to the StandardImport and marks original source_file as archived" do
        standards_import = create(:standards_import, :with_files)
        source_file = SourceFile.last

        perform_enqueued_jobs do
          allow(DocToPdfConverter).to receive(:convert).and_return(nil)
          expect { described_class.new.perform(source_file) }
            .to change { standards_import.files.count }.by(0)
          expect(source_file.reload).to be_archived
        end
      end
    end

    context "with already archived source file" do
      it "exits without creating new files" do
        standards_import = create(:standards_import, :with_docx_file_with_attachments)
        source_file = SourceFile.last
        source_file.archived!

        perform_enqueued_jobs do
          allow(DocToPdfConverter).to receive(:convert).and_return(nil)
          expect { described_class.new.perform(source_file) }
            .to change { StandardsImport.count }.by(0)
          expect(standards_import.files.count).to eq 1
        end
      end
    end
  end
end
