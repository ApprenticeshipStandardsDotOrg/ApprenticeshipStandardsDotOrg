require "rails_helper"

RSpec.describe Scraper::ExportFileAttachmentsJob do
  describe "#perform" do
    it "creates a StandardImport and 6 files attached to it" do
      create(:standards_import, :with_docx_file_with_attachments)
      source_file = SourceFile.last

      perform_enqueued_jobs do
        allow(DocToPdfConverter).to receive(:convert).and_return(nil)
        expect { described_class.new.perform(source_file) }
          .to change { StandardsImport.count }.by(1)
          .and change { StandardsImport.last.files.count }.by(6)
      end
    end

    context "with file that doesn't have attachments" do
      it "does not create a StandardImport" do
        create(:standards_import, :with_files)
        source_file = SourceFile.last

        perform_enqueued_jobs do
          allow(DocToPdfConverter).to receive(:convert).and_return(nil)
          expect { described_class.new.perform(source_file) }
            .to change { StandardsImport.count }.by(0)
        end
      end
    end
  end
end
