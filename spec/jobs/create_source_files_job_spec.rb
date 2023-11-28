require 'rails_helper'

RSpec.describe CreateSourceFilesJob, type: :job do
  describe "#perform" do
    it "creates source file records" do
      StandardsImport.skip_callback(:commit, :after, :create_source_files)

      file1 = file_fixture("pixel1x1.pdf")
      file2 = file_fixture("pixel1x1.jpg")
      import = create(:standards_import, files: [file1, file2])

      expect { 
        described_class.new.perform(import)
      }.to change(SourceFile, :count).by(2)

      source_file1 = SourceFile.first
      source_file2 = SourceFile.last
      expect(source_file1.active_storage_attachment).to eq import.files.first
      expect(source_file2.active_storage_attachment).to eq import.files.last

      StandardsImport.set_callback(:commit, :after, :create_source_files)
    end

    it "publishes error message if creating import record fails" do
      StandardsImport.skip_callback(:commit, :after, :create_source_files)

      import = create(:standards_import, :with_files)
      error = StandardError.new("some error")
      allow(SourceFile).to receive(:find_or_create_by!).and_raise(error)

      expect_any_instance_of(ErrorSubscriber).to receive(:report).and_call_original
      expect {
        described_class.new.perform(import)
      }.to_not change(SourceFile, :count)

      StandardsImport.set_callback(:commit, :after, :create_source_files)
    end
  end
end
