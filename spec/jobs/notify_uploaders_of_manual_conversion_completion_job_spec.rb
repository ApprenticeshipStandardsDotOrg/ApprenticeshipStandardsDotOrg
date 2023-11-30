require "rails_helper"

RSpec.describe NotifyUploadersOfManualConversionCompletionJob, type: :job do
  describe "#perform" do
    context "without email as a parameter" do
      it "new.performs mailer with list of source files" do
        import1 = create(:standards_import, email: "foo@example.com", name: "Foo")
        source_file1a = create(:source_file)
        source_file1b = create(:source_file)
        allow(import1).to receive(:source_files_in_need_of_notification).and_return([source_file1a, source_file1b])

        import2 = create(:standards_import, email: "bar@example.com", name: "Bar")
        source_file2a = create(:source_file)
        source_file2b = create(:source_file)
        allow(import2).to receive(:source_files_in_need_of_notification).and_return([source_file2a, source_file2b])

        allow(StandardsImport).to receive(:manual_submissions_in_need_of_courtesy_notification).and_return([import1, import2])

        mailer = double("mailer", deliver_now: nil)

        expect(GuestMailer).to receive(:manual_upload_conversion_complete).with(email: "foo@example.com", source_files: [source_file1a, source_file1b]).and_return(mailer)
        expect(GuestMailer).to receive(:manual_upload_conversion_complete).with(email: "bar@example.com", source_files: [source_file2a, source_file2b]).and_return(mailer)
        expect(mailer).to receive(:deliver_now).twice

        described_class.new.perform

        expect(source_file1a.reload).to be_courtesy_notification_completed
        expect(source_file1b.reload).to be_courtesy_notification_completed
        expect(source_file2a.reload).to be_courtesy_notification_completed
        expect(source_file2b.reload).to be_courtesy_notification_completed

        expect(import1.reload).to be_courtesy_notification_completed
        expect(import2.reload).to be_courtesy_notification_completed
      end
    end

    context "with email as a parameter" do
      it "new.performs mailer with list of source files" do
        import1 = create(:standards_import, email: "foo@example.com", name: "Foo")
        source_file1a = create(:source_file)
        source_file1b = create(:source_file)
        allow(import1).to receive(:source_files_in_need_of_notification).and_return([source_file1a, source_file1b])

        allow(StandardsImport).to receive(:manual_submissions_in_need_of_courtesy_notification).with(email: "foo@example.com").and_return([import1])

        mailer = double("mailer", deliver_now: nil)

        expect(GuestMailer).to receive(:manual_upload_conversion_complete).with(email: "foo@example.com", source_files: [source_file1a, source_file1b]).and_return(mailer)
        expect(mailer).to receive(:deliver_now)

        described_class.new.perform(email: "foo@example.com")

        expect(source_file1a.reload).to be_courtesy_notification_completed
        expect(source_file1b.reload).to be_courtesy_notification_completed

        expect(import1.reload).to be_courtesy_notification_completed
      end
    end
  end
end
