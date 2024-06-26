require "rails_helper"

RSpec.describe StandardsImport, type: :model do
  it "has a valid factory" do
    import = build(:standards_import)

    expect(import).to be_valid
  end

  it "requires email if courtesy_notification is other than not_required" do
    import = build(:standards_import, email: nil, courtesy_notification: :pending)

    expect(import).to_not be_valid

    import = build(:standards_import, email: nil, courtesy_notification: :completed)

    expect(import).to_not be_valid

    import = build(:standards_import, email: nil, courtesy_notification: :not_required)

    expect(import).to be_valid
  end

  it "normalizes email" do
    import = create(:standards_import, email: " FOO@example.COM  ")

    expect(import.reload.email).to eq "foo@example.com"
  end

  it "requires name if courtesy_notification is other than not_required" do
    import = build(:standards_import, name: nil, courtesy_notification: :pending)

    expect(import).to_not be_valid

    import = build(:standards_import, name: nil, courtesy_notification: :completed)

    expect(import).to_not be_valid

    import = build(:standards_import, name: nil, courtesy_notification: :not_required)

    expect(import).to be_valid
  end

  it "normalizes name" do
    import = create(:standards_import, name: " Mickey   Mouse  ")

    expect(import.reload.name).to eq "Mickey Mouse"
  end

  it "deletes file import record when deleted" do
    perform_enqueued_jobs do
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
  end

  describe "imports" do
    it "builds a tree of imports" do
      standards_import = create(:standards_import)
      standards_import.imports.build(attributes_for(:imports_uncategorized, parent: nil))
      uncategorized = standards_import.imports.first
      uncategorized.build_import(attributes_for(:imports_docx_listing, parent: nil))
      docx_listing = uncategorized.import
      docx_listing.imports.build(attributes_for(:imports_docx, parent: nil))
      docx = docx_listing.imports.first
      docx.build_pdf(attributes_for(:imports_pdf, parent: nil))

      expect(standards_import.save).to be_truthy
      standards_import.reload

      expect(standards_import.imports.count).to eq(1)
      expect(standards_import.imports.first).to be_an(Imports::Uncategorized)
      expect(standards_import.imports.first.import).to be_an(Imports::DocxListing)
      expect(standards_import.imports.first.import.imports.count).to eq(1)
      expect(standards_import.imports.first.import.imports.first).to be_an(Imports::Docx)
      expect(standards_import.imports.first.import.imports.first.pdf).to be_an(Imports::Pdf)
    end
  end

  describe ".manual_submissions_in_need_of_courtesy_notification" do
    context "with imports feature flag off" do
      context "when no email passed" do
        it "returns all standards imports that need notification" do
          perform_enqueued_jobs do
            file1 = file_fixture("pixel1x1.pdf")
            file2 = file_fixture("pixel1x1.jpg")

            # Import needs notifiying since user has not been notified about the
            # second file being completed
            import1 = create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
            source_file1a = SourceFile.first
            source_file1a.completed! # Conversion is complete
            source_file1a.courtesy_notification_completed! # User notified
            source_file1b = SourceFile.last
            source_file1b.completed! # Conversion is complete

            # Import needs notifiying since user has not been notified about single
            # file conversion being completed
            import2 = create(:standards_import, :with_files, courtesy_notification: :pending, email: "foo2@example.com", name: "Foo2")
            source_file2 = SourceFile.last
            source_file2.completed! # Conversion is complete

            # Import does NOT need notifiying since user has been notified about the
            # second file, but first file conversion is not complete.
            create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo3@example.com", name: "Foo3")
            source_file3 = SourceFile.last
            source_file3.completed! # Conversion is complete
            source_file3.courtesy_notification_completed! # User notified

            # Import does NOT need notifiying since import courtesy notification
            # is marked as completed.
            create(:standards_import, :with_files, courtesy_notification: :completed, email: "foo4@example.com", name: "Foo4")

            # Import does NOT need notifiying since import courtesy notification
            # is marked as not_required.
            create(:standards_import, :with_files, courtesy_notification: :not_required)

            expect(described_class.manual_submissions_in_need_of_courtesy_notification).to contain_exactly(import1, import2)
          end
        end
      end

      context "when email passed" do
        it "only returns imports that match the email" do
          perform_enqueued_jobs do
            file1 = file_fixture("pixel1x1.pdf")
            file2 = file_fixture("pixel1x1.jpg")

            # Import needs notifiying since user has not been notified about the
            # second file being completed
            import1 = create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "FOO@example.com ", name: "Foo")
            source_file1a = SourceFile.first
            source_file1a.completed! # Conversion is complete
            source_file1a.courtesy_notification_completed! # User notified
            source_file1b = SourceFile.last
            source_file1b.completed! # Conversion is complete

            # Import needs notifiying since user has not been notified about single
            # file conversion being completed
            create(:standards_import, :with_files, courtesy_notification: :pending, email: "notfoo@example.com", name: "Not Foo")
            source_file2 = SourceFile.last
            source_file2.completed! # Conversion is complete

            expect(described_class.manual_submissions_in_need_of_courtesy_notification(email: " foo@EXAMPLE.COM")).to contain_exactly(import1)
          end
        end
      end
    end

    context "with imports feature flag on" do
      before { stub_feature_flag(:show_imports_in_administrate, true) }
      after { stub_feature_flag(:show_imports_in_administrate, false) }

      context "when no email passed" do
        it "returns all standards imports that need notification" do
          # StandardsImport needs notifiying since user has not been notified
          # about the second file being completed
          standards_import1 = create(:standards_import, courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
          uncat1a = create(:imports_uncategorized, parent: standards_import1)
          pdf1a = create(:imports_pdf, parent: uncat1a, status: :completed, courtesy_notification: :completed)
          uncat1b = create(:imports_uncategorized, parent: standards_import1)
          pdf1b = create(:imports_pdf, parent: uncat1b, status: :completed, courtesy_notification: :pending)

          # StandardsImport needs notifiying since user has not been notified
          # about single file conversion being completed
          standards_import2 = create(:standards_import, courtesy_notification: :pending, email: "foo2@example.com", name: "Foo2")
          uncat2 = create(:imports_uncategorized, parent: standards_import2)
          pdf2 = create(:imports_pdf, parent: uncat2, status: :completed, courtesy_notification: :pending)

          # StandardsImport does NOT need notifiying since user has been
          # notified about the second file, but first file conversion is not
          # complete.
          standards_import3 = create(:standards_import, courtesy_notification: :pending, email: "foo3@example.com", name: "Foo3")
          uncat3 = create(:imports_uncategorized, parent: standards_import3)
          pdf3 = create(:imports_pdf, parent: uncat3, status: :completed, courtesy_notification: :completed)

          # Import does NOT need notifiying since import courtesy notification
          # is marked as completed.
          create(:standards_import, courtesy_notification: :completed, email: "foo4@example.com", name: "Foo4")

          # Import does NOT need notifiying since import courtesy notification
          # is marked as not_required.
          create(:standards_import, courtesy_notification: :not_required)

          expect(described_class.manual_submissions_in_need_of_courtesy_notification).to contain_exactly(standards_import1, standards_import2)
        end
      end

      context "when email passed" do
        it "only returns imports that match the email" do
          # Import needs notifiying since user has not been notified about the
          # second file being completed
          standards_import1 = create(:standards_import, courtesy_notification: :pending, email: "FOO@example.com ", name: "Foo")
          uncat1a = create(:imports_uncategorized, parent: standards_import1)
          pdf1a = create(:imports_pdf, parent: uncat1a, status: :completed, courtesy_notification: :completed)
          uncat1b = create(:imports_uncategorized, parent: standards_import1)
          pdf1b = create(:imports_pdf, parent: uncat1b, status: :completed, courtesy_notification: :pending)

          # Import does not need notifiying since email doesn't match
          standards_import2 = create(:standards_import, courtesy_notification: :pending, email: "notfoo@example.com", name: "Not Foo")
          uncat2 = create(:imports_uncategorized, parent: standards_import2)
          create(:imports_pdf, parent: uncat2, status: :completed, courtesy_notification: :pending)

          expect(described_class.manual_submissions_in_need_of_courtesy_notification(email: " foo@EXAMPLE.COM")).to contain_exactly(standards_import1)
        end
      end
    end
  end

  describe "source_file creation" do
    it "without import flag: calls CreateSourceFileJob" do
      expect(CreateSourceFileJob).to receive(:perform_later).twice

      file1 = file_fixture("pixel1x1.pdf")
      file2 = file_fixture("pixel1x1.jpg")
      create(:standards_import, files: [file1, file2])
    end

    it "with import flag: does not call CreateSourceFileJob" do
      stub_feature_flag(:show_imports_in_administrate, true)

      expect(CreateSourceFileJob).to_not receive(:perform_later)

      file = file_fixture("pixel1x1.pdf")
      create(:standards_import, files: [file])

      stub_feature_flag(:show_imports_in_administrate, false)
    end
  end

  describe "#source_files" do
    it "returns source files associated to each file attachment, alphabetically by filename" do
      perform_enqueued_jobs do
        file1 = file_fixture("pixel1x1.pdf")
        file2 = file_fixture("pixel1x1.jpg")
        file3 = file_fixture("pixel1x1-2.jpg")

        import = create(:standards_import, email: "foo@example.com", name: "Foo", files: [file1, file2, file3], courtesy_notification: :pending)
        source_file1 = SourceFile.first
        source_file2 = SourceFile.second
        source_file3 = SourceFile.last

        # Simulate an active storage attachment that does not have a source file
        # yet
        source_file3.destroy!

        create(:source_file)

        expect(import.source_files).to eq [source_file2, source_file1]
      end
    end
  end

  describe "#has_converted_source_file_in_need_of_notification?" do
    context "with imports feature flag off" do
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
          perform_enqueued_jobs do
            file1 = file_fixture("pixel1x1.pdf")
            file2 = file_fixture("pixel1x1.jpg")

            import = create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
            source_file1 = SourceFile.first
            source_file1.completed! # Conversion is complete
            source_file1.courtesy_notification_completed! # User notified
            source_file2 = SourceFile.last
            source_file2.completed! # Conversion is complete

            expect(import).to have_converted_source_file_in_need_of_notification
          end
        end

        it "is false if there are no completed coversions without courtesy notification needed" do
          perform_enqueued_jobs do
            file1 = file_fixture("pixel1x1.pdf")
            file2 = file_fixture("pixel1x1.jpg")

            # First file has been converted and notified. Second file has not
            # been converted.
            import = create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
            source_file = SourceFile.first
            source_file.completed! # Conversion is complete
            source_file.courtesy_notification_completed! # User notified

            expect(import).to_not have_converted_source_file_in_need_of_notification
          end
        end
      end
    end

    context "with imports feature flag on" do
      before { stub_feature_flag(:show_imports_in_administrate, true) }
      after { stub_feature_flag(:show_imports_in_administrate, false) }

      context "when courtesy notification is not_required" do
        it "is false" do
          standards_import = build(:standards_import, courtesy_notification: :not_required)

          expect(standards_import).to_not have_converted_source_file_in_need_of_notification
        end
      end

      context "when courtesy notification is completed" do
        it "is false" do
          standards_import = build(:standards_import, courtesy_notification: :completed)

          expect(standards_import).to_not have_converted_source_file_in_need_of_notification
        end
      end

      context "when courtesy notification is pending" do
        it "is true if at least one pdf conversion is complete but courtesy notification is marked as pending" do
          standards_import = create(:standards_import, courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
          uncat1 = create(:imports_uncategorized, parent: standards_import)
          pdf1 = create(:imports_pdf, parent: uncat1, status: :completed, courtesy_notification: :completed)

          uncat2 = create(:imports_uncategorized, parent: standards_import)
          pdf2 = create(:imports_pdf, parent: uncat2, status: :completed, courtesy_notification: :pending)

          expect(standards_import).to have_converted_source_file_in_need_of_notification
        end

        it "is false if there are no completed coversions without courtesy notification needed" do
          # First file has been converted and notified. Second file has not
          # been converted.
          standards_import = create(:standards_import, courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
          uncat1 = create(:imports_uncategorized, parent: standards_import)
          create(:imports_pdf, parent: uncat1, status: :completed, courtesy_notification: :completed)
          uncat2 = create(:imports_uncategorized, parent: standards_import)
          create(:imports_pdf, parent: uncat2, status: :pending, courtesy_notification: :pending)

          expect(standards_import).to_not have_converted_source_file_in_need_of_notification
        end
      end
    end
  end

  describe "#source_files_in_need_of_notification" do
    context "with imports feature flag off" do
      context "when courtesy notification is not_required" do
        it "is empty" do
          import = create(:standards_import, courtesy_notification: :not_required)

          expect(import.source_files_in_need_of_notification).to be_empty
        end
      end

      context "when courtesy notification is completed" do
        it "is empty" do
          import = create(:standards_import, courtesy_notification: :completed, email: "foo@example.com", name: "Foo")

          expect(import.source_files_in_need_of_notification).to be_empty
        end
      end

      context "when courtesy notification is pending" do
        it "returns source files such that conversion is complete but courtesy notification is marked as pending" do
          perform_enqueued_jobs do
            file1 = file_fixture("pixel1x1.pdf")
            file2 = file_fixture("pixel1x1.jpg")

            import = create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
            source_file1 = SourceFile.first
            source_file1.completed! # Conversion is complete
            source_file1.courtesy_notification_completed! # User notified
            source_file2 = SourceFile.last
            source_file2.completed! # Conversion is complete

            expect(import.source_files_in_need_of_notification).to eq [source_file2]
          end
        end

        it "is empty if there are no completed coversions without courtesy notification needed" do
          perform_enqueued_jobs do
            file1 = file_fixture("pixel1x1.pdf")
            file2 = file_fixture("pixel1x1.jpg")

            # First file has been converted and notified. Second file has not
            # been converted.
            import = create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
            source_file = SourceFile.first
            source_file.completed! # Conversion is complete
            source_file.courtesy_notification_completed! # User notified

            expect(import.source_files_in_need_of_notification).to be_empty
          end
        end
      end
    end

    context "with imports feature flag on" do
      before { stub_feature_flag(:show_imports_in_administrate, true) }
      after { stub_feature_flag(:show_imports_in_administrate, false) }

      context "when courtesy notification is not_required" do
        it "is empty" do
          import = create(:standards_import, courtesy_notification: :not_required)

          expect(import.source_files_in_need_of_notification).to be_empty
        end
      end

      context "when courtesy notification is completed" do
        it "is empty" do
          import = create(:standards_import, courtesy_notification: :completed, email: "foo@example.com", name: "Foo")

          expect(import.source_files_in_need_of_notification).to be_empty
        end
      end

      context "when courtesy notification is pending" do
        it "returns pdf imports such that conversion is complete but courtesy notification is marked as pending" do
          standards_import = create(:standards_import, courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
          uncat1 = create(:imports_uncategorized, parent: standards_import)
          uncat2 = create(:imports_uncategorized, parent: standards_import)
          pdf1 = create(:imports_pdf, parent: uncat1, status: :completed, courtesy_notification: :completed) # Conversion is completed and user notified
          pdf2 = create(:imports_pdf, parent: uncat2, status: :completed, courtesy_notification: :pending) # Conversion is completed but user not notified

          expect(standards_import.source_files_in_need_of_notification).to eq [pdf2]
        end

        it "is empty if there are no completed coversions without courtesy notification needed" do
          # First file has been converted and notified. Second file has not
          # been converted.
          standards_import = create(:standards_import, courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
          uncat1 = create(:imports_uncategorized, parent: standards_import)
          uncat2 = create(:imports_uncategorized, parent: standards_import)
          pdf1 = create(:imports_pdf, parent: uncat1, status: :completed, courtesy_notification: :completed) # Conversion is completed and user notified
          pdf2 = create(:imports_pdf, parent: uncat2, status: :pending) # Conversion not completed

          expect(standards_import.source_files_in_need_of_notification).to be_empty
        end
      end
    end
  end

  describe "#has_notified_uploader_of_all_conversions?" do
    it "is true if source file total matches courtesy notification total" do
      perform_enqueued_jobs do
        file1 = file_fixture("pixel1x1.pdf")
        file2 = file_fixture("pixel1x1.jpg")

        import = create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
        source_file1 = SourceFile.first
        source_file1.completed! # Conversion is complete
        source_file1.courtesy_notification_completed! # User notified
        source_file2 = SourceFile.last
        source_file2.completed! # Conversion is complete
        source_file2.courtesy_notification_completed! # User notified

        expect(import.has_notified_uploader_of_all_conversions?).to be true
      end
    end

    it "is false if source file total does not match courtesy notification total" do
      perform_enqueued_jobs do
        file1 = file_fixture("pixel1x1.pdf")
        file2 = file_fixture("pixel1x1.jpg")

        import = create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
        source_file1 = SourceFile.first
        source_file1.completed! # Conversion is complete
        source_file1.courtesy_notification_completed! # User notified
        source_file2 = SourceFile.last
        source_file2.completed! # Conversion is complete

        expect(import.has_notified_uploader_of_all_conversions?).to be false
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

  describe "#pdf_leaves" do
    it "returns all the pdf descendants" do
      standards_import = create(:standards_import)

      # Uncat -> Doc -> Pdf
      uncat_doc = create(:imports_uncategorized, :doc, parent: standards_import)
      doc = create(:imports_doc, parent: uncat_doc)
      pdf_from_doc = create(:imports_pdf, parent: doc)

      # Uncat -> Docx -> Pdf
      uncat_docx = create(:imports_uncategorized, :docx, parent: standards_import)
      docx = create(:imports_docx, parent: uncat_docx)
      pdf_from_docx = create(:imports_pdf, parent: docx)

      # Uncat -> Pdf
      uncat_pdf = create(:imports_uncategorized, :pdf, parent: standards_import)
      pdf = create(:imports_pdf, parent: uncat_pdf)

      # Uncat -> DocxListing -> multiple pdfs
      uncat_docx_listing = create(:imports_uncategorized, :docx_listing, parent: standards_import)
      docx_listing = create(:imports_docx_listing, parent: uncat_docx_listing)
      uncat1 = create(:imports_uncategorized, parent: docx_listing)
      uncat2 = create(:imports_uncategorized, parent: docx_listing)
      uncat3 = create(:imports_uncategorized, parent: docx_listing)

      listing_doc = create(:imports_doc, parent: uncat1)
      pdf1 = create(:imports_pdf, parent: listing_doc)

      listing_docx = create(:imports_docx, parent: uncat2)
      pdf2 = create(:imports_pdf, parent: listing_docx)

      pdf3 = create(:imports_pdf, parent: uncat3)

      expect(standards_import.pdf_leaves).to contain_exactly(pdf_from_doc, pdf_from_docx, pdf, pdf1, pdf2, pdf3)
    end
  end
end
