require "rails_helper"

RSpec.describe StandardsImport, type: :model do
  it "has a valid factory" do
    si = build(:standards_import)

    expect(si).to be_valid
  end

  it "deletes file import record when deleted" do
    standards_import = create(:standards_import, :with_files)
    attachment = standards_import.files.first
    source_file = attachment.source_file

    expect(attachment).to be
    expect(source_file).to be

    expect {
      standards_import.destroy!
    }.to change(ActiveStorage::Attachment, :count).by(-1)
      .and change(SourceFile, :count).by(-1)

    expect { attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { source_file.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe "#create_source_files!" do
    it "creates a source file record when saved" do
      file1 = file_fixture("pixel1x1.pdf")
      file2 = file_fixture("pixel1x1.jpg")
      import = build(:standards_import, files: [file1, file2])

      expect { import.save! }.to change(SourceFile, :count).by(2)

      source_file1 = SourceFile.first
      source_file2 = SourceFile.last
      expect(source_file1.active_storage_attachment).to eq import.files.first
      expect(source_file2.active_storage_attachment).to eq import.files.last
    end

    it "publishes error message if creating import record fails" do
      import = build(:standards_import, :with_files)
      error = StandardError.new("some error")
      allow(SourceFile).to receive(:find_or_create_by!).and_raise(error)

      expect_any_instance_of(ErrorSubscriber).to receive(:report).and_call_original
      expect { import.save! }.to_not change(SourceFile, :count)
    end
  end

  describe "#file_count" do
    it "returns file count" do
      si = create(:standards_import, :with_files)

      expect(si.file_count).to eq 1
    end
  end

  describe "#notify_admin" do
    it "calls new_standards_import mailer" do
      si = build(:standards_import)

      mailer = double("mailer", deliver_later: nil)
      expect(AdminMailer).to receive(:new_standards_import).and_return(mailer)
      expect(mailer).to receive(:deliver_later)

      si.notify_admin
    end
  end
end
