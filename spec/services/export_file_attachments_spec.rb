require "rails_helper"

RSpec.describe ExportFileAttachments do
  describe "#call" do
    it "creates a StandardImport and 6 files attached to it" do
      create(:standards_import, :with_docx_file_with_attachments)
      source_file = SourceFile.last
      blob = source_file.active_storage_attachment.blob

      expect { described_class.new(source_file, blob).call }
        .to change { StandardsImport.count }.by(1)
        .and change { StandardsImport.last.files.count }.by(6)
    end
  end
end
