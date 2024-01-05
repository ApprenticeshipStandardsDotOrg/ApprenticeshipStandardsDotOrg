require "rails_helper"

RSpec.describe DocToPdfConverter do
  describe "#call" do
    it "raises error if libreoffice not installed" do
      source_file = build(:source_file)
      allow(Kernel).to receive(:system).with("command -v soffice").and_return false

      expect { DocToPdfConverter.call(source_file) }.to raise_exception DocToPdfConverter::DependencyNotFoundError
    end

    it "raises error if conversion failed" do
      source_file = build(:source_file)
      FileUtils.remove_dir(DocToPdfConverter::TMP_DIRECTORY, true) if File.exist?(DocToPdfConverter::TMP_DIRECTORY)
      allow(Kernel).to receive(:system).with("command -v soffice").and_return true
      allow(Kernel).to receive(:system).with(/soffice --headless --convert-to pdf .*/).and_return false

      expect { DocToPdfConverter.call(source_file) }.to raise_exception DocToPdfConverter::FileConversionError
      expect(Dir).to exist(DocToPdfConverter::TMP_DIRECTORY)
    end

    it "returns true if document converted succesfully" do
      source_file = build(:source_file)
      FileUtils.remove_dir(DocToPdfConverter::TMP_DIRECTORY, true) if File.exist?(DocToPdfConverter::TMP_DIRECTORY)
      allow(Kernel).to receive(:system).with("command -v soffice").and_return true
      allow(Kernel).to receive(:system).with(/soffice --headless --convert-to pdf .*/).and_return true

      expect(DocToPdfConverter.call(source_file)).to be true
      expect(Dir).to exist(DocToPdfConverter::TMP_DIRECTORY)
    end
  end
end
