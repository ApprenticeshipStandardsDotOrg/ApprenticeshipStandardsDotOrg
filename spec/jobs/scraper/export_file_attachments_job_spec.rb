require "rails_helper"

RSpec.describe Scraper::ExportFileAttachmentsJob do
  describe "#perform" do
    context "with file that has attachments" do
      it "attaches 7 files to original standards_import file, marks original source_file as archived, and is idempotent" do
        # When viewing this file it looks to only have 6 attachments, but when
        # the files are extracted, there are 2 Word docs and 5 PDFs. Not sure
        # why only 4 PDFs are visible when viewing the doc.
        perform_enqueued_jobs do
          allow(DocToPdfConverter).to receive(:convert).and_return(nil)
          standards_import = create(:standards_import, :with_docx_file_with_attachments)
          source_file = SourceFile.last

          expect { described_class.new.perform(source_file) }
            .to change { StandardsImport.count }.by(0)
            .and change { ActiveStorage::Attachment.count }.by(7)
          expect(standards_import.files.count).to eq 8
          expect(source_file.reload).to be_archived

          # Simulate something breaking in the middle of the job where the files
          # got attached but the source_file never got marked as archived. If
          # the job is run again, do not re-attach the embedded files.
          source_file.pending!

          expect { described_class.new.perform(source_file) }
            .to change { StandardsImport.count }.by(0)
            .and change { ActiveStorage::Attachment.count }.by(0)
          expect(standards_import.files.count).to eq 8
        end
      end
    end

    context "with file that doesn't have attachments" do
      it "does not attach any files to the StandardImport and marks original source_file as archived" do
        perform_enqueued_jobs do
          allow(DocToPdfConverter).to receive(:convert).and_return(nil)
          standards_import = create(:standards_import, :with_files)
          source_file = SourceFile.last

          expect { described_class.new.perform(source_file) }
            .to change { standards_import.files.count }.by(0)
          expect(source_file.reload).to be_archived
        end
      end
    end

    context "with already archived source file" do
      it "exits without creating new files" do
        perform_enqueued_jobs do
          allow(DocToPdfConverter).to receive(:convert).and_return(nil)
          standards_import = create(:standards_import, :with_docx_file_with_attachments)
          source_file = SourceFile.last
          source_file.archived!

          expect { described_class.new.perform(source_file) }
            .to change { StandardsImport.count }.by(0)
          expect(standards_import.files.count).to eq 1
        end
      end
    end
  end
end
