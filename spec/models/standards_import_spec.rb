require "rails_helper"

RSpec.describe StandardsImport, type: :model do
  it "has a valid factory" do
    si = build(:standards_import)

    expect(si).to be_valid
  end

  it "deletes file import record when deleted" do
    standards_import = create(:standards_import, :with_files)
    attachment = standards_import.files.first
    file_import = attachment.file_import

    expect(attachment).to be
    expect(file_import).to be

    expect {
      standards_import.destroy!
    }.to change(ActiveStorage::Attachment, :count).by(-1)
      .and change(FileImport, :count).by(-1)

    expect { attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { file_import.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe "#file_count" do
    it "returns file count" do
      si = create(:standards_import, :with_files)

      expect(si.file_count).to eq 1
    end
  end

  describe "#notify_admin" do
    it "calls new_standards_import mailer on create but not update" do
      stub_const "ENV", ENV.to_h.merge("ENABLE_STANDARDS_IMPORTS_NOTIFICATIONS" => "true")
      si = build(:standards_import)

      mailer = double("mailer", deliver_later: nil)
      expect(AdminMailer).to receive(:new_standards_import).and_return(mailer)
      expect(mailer).to receive(:deliver_later)

      si.save!

      expect(AdminMailer).to_not receive(:new_standards_import)

      si.update!(name: "Minnie Mouse")
    end
  end
end
