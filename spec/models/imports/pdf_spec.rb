require "rails_helper"

RSpec.describe Imports::Pdf, type: :model do
  it_behaves_like "an imported file"

  it "updates the processing data" do
    pdf = create(:imports_pdf)

    pdf.process
    pdf.reload

    expect(pdf.processed_at).to be_present
    expect(pdf.processing_errors).to be_blank
    expect(pdf.status).to eq("pending")
  end

  describe ".recently_redacted" do
    it "returns records created the day before by default" do
      travel_to(Time.zone.local(2023, 6, 15)) do
        recent_records = [
          create(:imports_pdf, redacted_at: Time.zone.local(2023, 6, 14)),
          create(:imports_pdf, redacted_at: Time.zone.local(2023, 6, 14, 23, 59, 59))
        ]
        create(:imports_pdf, redacted_at: Time.zone.local(2023, 6, 13, 23, 59, 59))

        expect(described_class.recently_redacted).to match_array recent_records
      end
    end

    it "returns records within the passed start and end time" do
      recent_records = [
        create(:imports_pdf, redacted_at: Time.zone.local(2022, 6, 14)),
        create(:imports_pdf, redacted_at: Time.zone.local(2022, 6, 14, 22, 59, 59))
      ]
      create(:imports_pdf, redacted_at: Time.zone.local(2022, 6, 14, 23, 59, 59))

      start_time = Time.zone.local(2022, 6, 14)
      end_time = Time.zone.local(2022, 6, 14, 23)
      expect(described_class.recently_redacted(start_time: start_time, end_time: end_time)).to match_array recent_records
    end
  end

  describe ".not_redacted" do
    it "returns only Imports::Pdf without redacted pdf" do
      create(:imports_pdf, :with_redacted_pdf)
      import_without_redacted_pdf = create(:imports_pdf, :without_redacted_pdf)

      expect(described_class.not_redacted).to eq [import_without_redacted_pdf]
    end
  end

  describe ".ready_for_redaction" do
    it "returns only private imports without attachment and completed" do
      import_with_all_conditions = create(:imports_pdf,
        :without_redacted_pdf,
        :completed)

      _import_not_complete = create(:imports_pdf,
        :without_redacted_pdf,
        :pending)

      _import_with_redacted_pdf = create(:imports_pdf,
        :with_redacted_pdf,
        :completed)

      _import_public = create(:imports_pdf,
        :without_redacted_pdf,
        :completed,
        public_document: true)

      expect(described_class.ready_for_redaction).to eq [import_with_all_conditions]
    end
  end

  describe ".already_redacted" do
    it "returns only source files that are already redacted" do
      import_with_redacted_pdf = create(:imports_pdf, :with_redacted_pdf)
      create(:imports_pdf, :without_redacted_pdf)

      expect(described_class.already_redacted).to eq [import_with_redacted_pdf]
    end
  end

  describe "#redacted_pdf_url" do
    it "returns nil if file not present" do
      import = build(:imports_pdf, redacted_pdf: nil)

      expect(import.redacted_pdf_url).to be nil
    end

    it "returns file url if file present", :url_generation do
      import = build(:imports_pdf, redacted_pdf: fixture_file_upload("pixel1x1.jpg", "image/jpeg"))

      expect(import.redacted_pdf_url).to be_present
    end
  end

  describe "#file_for_redaction" do
    it "returns redacted_pdf if present" do
      import = build(:imports_pdf, redacted_pdf: fixture_file_upload("pixel1x1.jpg", "image/jpeg"))

      expect(import.file_for_redaction).to eq import.redacted_pdf
    end

    it "returns file if redacted_pdf is not present" do
      import = create(:imports_pdf, redacted_pdf: nil)

      expect(import.file_for_redaction).to eq import.file
    end
  end

  describe "#associated_occupation_standards" do
    it "returns unique occupation standards" do
      import = create(:imports_pdf)
      occupation_standard = create(:occupation_standard)
      create_pair(:data_import, import: import, occupation_standard: occupation_standard)

      expect(import.associated_occupation_standards).to eq [occupation_standard]
    end
  end

  describe "#import_root" do
    it "retrieves the standards_import at the root" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      docx_listing = create(:imports_docx_listing, parent: uncat)
      pdf = create(:imports_pdf, parent: docx_listing)

      expect(pdf.import_root).to eq standards_import
    end
  end

  describe "#pdf_leaf" do
    it "returns self" do
      pdf = create(:imports_pdf)

      expect(pdf.pdf_leaf).to eq pdf
    end
  end
end
