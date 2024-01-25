require "rails_helper"

RSpec.describe DocxFile do
  include ActionDispatch::TestProcess::FixtureFile

  describe ".has_embedded_files?" do
    it "it is true if the file has embeds" do
      file = file_fixture_upload("docx_file_attachments.docx")
      expect(described_class.has_embedded_files?(file)).to be_truthy
    end

    it "is false if the file doesn't have embeds" do
      file = file_fixture_upload("document.docx")
      expect(described_class.has_embedded_files?(file)).to be_falsey
    end

    it "is false if the file has no content" do
      Tempfile.create do |f|
        expect(described_class.has_embedded_files?(f)).to be_falsey
      end
    end
  end
end
