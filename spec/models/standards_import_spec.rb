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

  describe ".manual_submissions_in_need_of_courtesy_notification" do
    context "when no email passed" do
      it "returns all standards imports that need notification" do
        file1 = file_fixture("pixel1x1.pdf")
        file2 = file_fixture("pixel1x1.jpg")

        # Import needs notifiying since user has not been notified about the
        # second file being completed
        import1 = create(:standards_import, files: [file1, file2], courtesy_notification: :pending)
        source_file1a = SourceFile.first
        source_file1a.completed! # Conversion is complete
        source_file1a.courtesy_notification_completed! # User notified
        source_file1b = SourceFile.last
        source_file1b.completed! # Conversion is complete

        # Import needs notifiying since user has not been notified about single
        # file conversion being completed
        import2 = create(:standards_import, :with_files, courtesy_notification: :pending)
        source_file2 = SourceFile.last
        source_file2.completed! # Conversion is complete

        # Import does NOT need notifiying since user has been notified about the
        # second file, but first file conversion is not complete.
        create(:standards_import, files: [file1, file2], courtesy_notification: :pending)
        source_file3 = SourceFile.last
        source_file3.completed! # Conversion is complete
        source_file3.courtesy_notification_completed! # User notified

        # Import does NOT need notifiying since import courtesy notification
        # is marked as completed.
        create(:standards_import, :with_files, courtesy_notification: :completed)

        # Import does NOT need notifiying since import courtesy notification
        # is marked as not_required.
        create(:standards_import, :with_files, courtesy_notification: :not_required)

        expect(described_class.manual_submissions_in_need_of_courtesy_notification).to contain_exactly(import1, import2)
      end
    end

    context "when email passed" do
      it "only returns imports that match the email" do
        file1 = file_fixture("pixel1x1.pdf")
        file2 = file_fixture("pixel1x1.jpg")

        # Import needs notifiying since user has not been notified about the
        # second file being completed
        import1 = create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo@example.com")
        source_file1a = SourceFile.first
        source_file1a.completed! # Conversion is complete
        source_file1a.courtesy_notification_completed! # User notified
        source_file1b = SourceFile.last
        source_file1b.completed! # Conversion is complete

        # Import needs notifiying since user has not been notified about single
        # file conversion being completed
        import2 = create(:standards_import, :with_files, courtesy_notification: :pending, email: "notfoo@example.com")
        source_file2 = SourceFile.last
        source_file2.completed! # Conversion is complete

        expect(described_class.manual_submissions_in_need_of_courtesy_notification(email: "foo@example.com")).to contain_exactly(import1)
      end
    end
  end

  describe "#create_source_files" do
    it "calls CreateSourceFiles background job" do
      expect(CreateSourceFilesJob).to receive(:perform_later).with(kind_of(StandardsImport))

      create(:standards_import)
    end
  end

  describe "#source_files" do
    it "returns source files associated to each file attachment" do
      file1 = file_fixture("pixel1x1.pdf")
      file2 = file_fixture("pixel1x1.jpg")

      import = create(:standards_import, files: [file1, file2], courtesy_notification: :pending)
      source_file1 = SourceFile.first
      source_file2 = SourceFile.last
      create(:source_file)

      expect(import.source_files).to contain_exactly(source_file1, source_file2)
    end
  end

  describe "#has_converted_source_file_in_need_of_notification?" do
    context "when courtesy notification is not_required" do
      it "is false" do
        import = build(:standards_import, courtesy_notification: :not_required)

        expect(import).to_not have_converted_source_file_in_need_of_notification
      end
    end

    context "when courtesy notification is completed" do
      it "is false" do
        import = build(:standards_import, courtesy_notification: :completed)

        expect(import).to_not have_converted_source_file_in_need_of_notification
      end
    end

    context "when courtesy notification is pending" do
      it "is true if at least one source file conversion is complete but courtesy notification is marked as pending" do
        file1 = file_fixture("pixel1x1.pdf")
        file2 = file_fixture("pixel1x1.jpg")

        import = create(:standards_import, files: [file1, file2], courtesy_notification: :pending)
        CreateSourceFilesJob.perform_now(import)
        source_file1 = SourceFile.first
        source_file1.completed! # Conversion is complete
        source_file1.courtesy_notification_completed! # User notified
        source_file2 = SourceFile.last
        source_file2.completed! # Conversion is complete

        expect(import).to have_converted_source_file_in_need_of_notification
      end

      it "is false if there are no completed coversions without courtesy notification" do
        file1 = file_fixture("pixel1x1.pdf")
        file2 = file_fixture("pixel1x1.jpg")

        # First file has been converted and notified. Second file has not
        # been converted.
        import = create(:standards_import, files: [file1, file2], courtesy_notification: :pending)
        CreateSourceFilesJob.perform_now(import)
        source_file = SourceFile.first
        source_file.completed! # Conversion is complete
        source_file.courtesy_notification_completed! # User notified

        expect(import).to_not have_converted_source_file_in_need_of_notification
      end
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
