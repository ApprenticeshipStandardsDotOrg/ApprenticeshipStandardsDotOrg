require "rails_helper"

RSpec.describe NotifyUploadsOfConversionsForPeriodJob, type: :job do
  describe "#perform" do
    it "raises error when period given is invalid" do
      expect { described_class.new.perform(date_range: 5..7) }
        .to raise_error described_class::InvalidDateRange
    end

    context "without email as a parameter", aggregate_failures: true do
      it "calls mailer with appropriate list of pdf imports" do
        date_range = 2.months.ago..1.month.ago
        email_1 = "tst1@example.com"
        email_2 = "tst2@example.com"

        standards_import_1 = create(:standards_import, email: email_1, name: "Tst1")
        _pdf1a = create(:imports_pdf, parent: standards_import_1, processed_at: 3.months.ago)
        pdf_1b = create(:imports_pdf, parent: standards_import_1, processed_at: 6.weeks.ago)
        allow(standards_import_1)
          .to receive(:source_files_processed_during_period)
          .with(date_range:, email: nil)
          .and_return([pdf_1b])

        standards_import_2 = create(:standards_import, email: email_2, name: "Tst2")
        pdf_2a = create(:imports_pdf, parent: standards_import_2, processed_at: 6.weeks.ago)
        _pdf2b = create(:imports_pdf, parent: standards_import_2, processed_at: 1.week.ago)
        allow(standards_import_2)
          .to receive(:source_files_processed_during_period)
          .with(date_range:, email: nil)
          .and_return([pdf_2a])

        allow(StandardsImport)
          .to receive(:manual_submissions_during_period)
          .with(date_range:, email: nil)
          .and_return([standards_import_1, standards_import_2])

        mailer = double("mailer", deliver_now: nil)

        expect(GuestMailer)
          .to receive(:manual_submissions_during_period)
          .with(date_range:, email: email_1, source_files: [pdf_1b])
          .and_return(mailer)
        expect(GuestMailer)
          .to receive(:manual_submissions_during_period)
          .with(date_range:, email: email_2, source_files: [pdf_2a])
          .and_return(mailer)
        expect(mailer).to receive(:deliver_now).twice

        described_class.new.perform(date_range:)
      end
    end

    context "with email as a parameter", aggregate_failures: true do
      it "calls mailer with list of imports for passed email only" do
        date_range = 2.months.ago..1.month.ago
        email_1 = "tst1@example.com"
        email_2 = "tst2@example.com"

        standards_import_1 = create(:standards_import, email: email_1, name: "Tst1")
        _pdf1a = create(:imports_pdf, parent: standards_import_1, processed_at: 3.months.ago)
        pdf_1b = create(:imports_pdf, parent: standards_import_1, processed_at: 6.weeks.ago)
        allow(standards_import_1)
          .to receive(:source_files_processed_during_period)
          .with(date_range:, email: email_1)
          .and_return([pdf_1b])
        allow(standards_import_1)
          .to receive(:source_files_processed_during_period)
          .with(date_range:, email: email_2)
          .and_return([])

        standards_import_2 = create(:standards_import, email: email_2, name: "Tst2")
        pdf_2a = create(:imports_pdf, parent: standards_import_2, processed_at: 6.weeks.ago)
        _pdf2b = create(:imports_pdf, parent: standards_import_2, processed_at: 1.week.ago)
        allow(standards_import_2)
          .to receive(:source_files_processed_during_period)
          .with(date_range:, email: email_1)
          .and_return([])
        allow(standards_import_2)
          .to receive(:source_files_processed_during_period)
          .with(date_range:, email: email_2)
          .and_return([pdf_2a])

        allow(StandardsImport)
          .to receive(:manual_submissions_during_period)
          .with(date_range:, email: email_1)
          .and_return([standards_import_1])
        allow(StandardsImport)
          .to receive(:manual_submissions_during_period)
          .with(date_range:, email: email_2)
          .and_return([standards_import_2])

        mailer = double("mailer", deliver_now: nil)

        expect(GuestMailer)
          .to receive(:manual_submissions_during_period)
          .with(date_range:, email: email_1, source_files: [pdf_1b])
          .and_return(mailer)
        expect(GuestMailer)
          .to receive(:manual_submissions_during_period)
          .with(date_range:, email: email_2, source_files: [pdf_2a])
          .and_return(mailer)
        expect(mailer).to receive(:deliver_now).twice

        described_class.new.perform(date_range:, email: email_1)
        described_class.new.perform(date_range:, email: email_2)
      end
    end
  end
end
