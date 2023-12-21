require "rails_helper"

RSpec.describe ExportFileAttachments do
  describe "#call" do
    it "creates a StandardImport and 6 files attached to it" do
      create(:standards_import, :with_docx_file_with_attachments)
      source_file = SourceFile.last

      expect { described_class.new(source_file).call }
        .to change { StandardsImport.count }.by(1)
        .and change { StandardsImport.last.files.count }.by(6)
    end

    context "with file that doesn't have attachments" do
      it "creates a StandardImport and 0 files attached to it" do
        create(:standards_import, :with_files)
        source_file = SourceFile.last

        expect { described_class.new(source_file).call }
          .to change { StandardsImport.count }.by(1)
        expect(StandardsImport.last.files.count).to eq(0)
      end
    end
  end
end
