require "rails_helper"

RSpec.describe NotifyUsersOfManualUploadConversionCompletion do
  describe "#call" do
    context "without email as a parameter" do
      it "calls mailer with list of source files" do
        import1 = create(:standards_import, email: "foo@example.com")
        source_file1a = create(:source_file)
        source_file1b = create(:source_file)
        allow(import1).to receive(:source_files_in_need_of_notification).and_return([source_file1a, source_file1b])

        import2 = create(:standards_import, email: "bar@example.com")
        source_file2a = create(:source_file)
        source_file2b = create(:source_file)
        allow(import2).to receive(:source_files_in_need_of_notification).and_return([source_file2a, source_file2b])

        allow(StandardsImport).to receive(:manual_submissions_in_need_of_courtesy_notification).and_return([import1, import2])

        mailer = double("mailer", deliver_later: nil)

        expect(GuestMailer).to receive(:manual_upload_conversion_complete).with(email: "foo@example.com", source_files: [source_file1a, source_file1b]).and_return(mailer)
        expect(GuestMailer).to receive(:manual_upload_conversion_complete).with(email: "bar@example.com", source_files: [source_file2a, source_file2b]).and_return(mailer)
        expect(mailer).to receive(:deliver_later).twice

        described_class.call
      end
    end
  end
end
