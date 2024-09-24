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

  describe "#docx_listing_root" do
    it "when descended from bulletin, retrieves the docx_listing ancestor" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      docx_listing = create(:imports_docx_listing, parent: uncat)
      uncat2 = create(:imports_uncategorized, parent: docx_listing)
      doc = create(:imports_doc, parent: uncat2)
      pdf = create(:imports_pdf, parent: doc)

      expect(pdf.docx_listing_root).to eq docx_listing
    end

    it "when not descended from bulletin, returns nil" do
      standards_import = create(:standards_import)
      uncat = create(:imports_uncategorized, parent: standards_import)
      doc = create(:imports_doc, parent: uncat)
      pdf = create(:imports_pdf, parent: doc)

      expect(pdf.docx_listing_root).to be_nil
    end
  end

  describe "#pdf_leaf" do
    it "returns self" do
      pdf = create(:imports_pdf)

      expect(pdf.pdf_leaf).to eq pdf
    end
  end

  describe "#pdf_leaves" do
    it "returns self in an array" do
      pdf = create(:imports_pdf)

      expect(pdf.pdf_leaves).to eq [pdf]
    end
  end

  describe "#cousins" do
    context "when descended from bulletin" do
      it "returns all the pdf_leaves of the docx_listing ancestor, excluding self" do
        docx_listing = create(:imports_docx_listing)
        uncat1 = create(:imports_uncategorized, parent: docx_listing)
        uncat2 = create(:imports_uncategorized, parent: docx_listing)
        uncat3 = create(:imports_uncategorized, parent: docx_listing)

        doc = create(:imports_doc, parent: uncat1)
        pdf1 = create(:imports_pdf, parent: doc, file: Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1_redacted.pdf"), "application/pdf"))

        docx = create(:imports_docx, parent: uncat2)
        pdf2 = create(:imports_pdf, parent: docx)

        pdf3 = create(:imports_pdf, parent: uncat3, file: Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"), "application/pdf"))

        expect(pdf2.cousins).to eq [pdf3, pdf1]
      end

      it "when only 1 document in bulletin returns empty array" do
        docx_listing = create(:imports_docx_listing)
        uncat = create(:imports_uncategorized, parent: docx_listing)
        doc = create(:imports_doc, parent: uncat)
        pdf = create(:imports_pdf, parent: doc)

        expect(pdf.cousins).to be_empty
      end
    end

    context "when not descended from bulletin" do
      it "returns empty array" do
        standards_import = create(:standards_import)
        uncat = create(:imports_uncategorized, parent: standards_import)
        doc = create(:imports_doc, parent: uncat)
        pdf = create(:imports_pdf, parent: doc)

        expect(pdf.cousins).to be_empty
      end
    end
  end

  describe "#available_for_redaction?" do
    it "returns true when import is not public document and completed" do
      pdf = create(:imports_pdf, public_document: false, status: :completed)

      expect(pdf.available_for_redaction?).to be true
    end

    it "returns false when import is not public document but pending" do
      pdf = create(:imports_pdf, public_document: false, status: :pending)

      expect(pdf.available_for_redaction?).to be false
    end

    it "returns false when import is public document and completed" do
      pdf = create(:imports_pdf, public_document: true, status: :completed)

      expect(pdf.available_for_redaction?).to be false
    end
  end

  describe "#notes" do
    context "when standards_import is public" do
      it "is blank" do
        standards_import = create(:standards_import, public_document: true, notes: "from some scraper job")
        uncat = create(:imports_uncategorized, parent: standards_import)
        pdf = create(:imports_pdf, parent: uncat)

        expect(pdf.notes).to be_blank
      end
    end

    context "when standards_import is not public" do
      it "returns standards_import notes" do
        standards_import = create(:standards_import, public_document: false, notes: "Please anonymize sponsor")
        uncat = create(:imports_uncategorized, parent: standards_import)
        pdf = create(:imports_pdf, parent: uncat)

        expect(pdf.notes).to eq "Please anonymize sponsor"
      end
    end
  end

  describe "#needs_courtesy_notification?" do
    it "is false if status is pending" do
      pdf = build(:imports_pdf, :pending)

      expect(pdf.needs_courtesy_notification?).to be false
    end

    it "is false if status is needs_support" do
      pdf = build(:imports_pdf, :needs_support)

      expect(pdf.needs_courtesy_notification?).to be false
    end

    it "is false if status is completed and courtesy_notification is completed" do
      pdf = build(:imports_pdf, :completed, courtesy_notification: :completed)

      expect(pdf.needs_courtesy_notification?).to be false
    end

    it "is false if status is completed and courtesy_notification is not_required" do
      pdf = build(:imports_pdf, :completed, courtesy_notification: :not_required)

      expect(pdf.needs_courtesy_notification?).to be false
    end

    it "is true if status is completed and courtesy_notification is pending" do
      pdf = build(:imports_pdf, :completed, courtesy_notification: :pending)

      expect(pdf.needs_courtesy_notification?).to be true
    end
  end

  describe "#organization" do
    context "when standards_import has organization" do
      it "returns standards_import organization" do
        standards_import = create(:standards_import, organization: "Urban")
        uncat = create(:imports_uncategorized, parent: standards_import)
        pdf = create(:imports_pdf, parent: uncat)

        expect(pdf.organization).to eq "Urban"
      end
    end

    context "when standards_import does not have organization" do
      it "is blank" do
        standards_import = create(:standards_import, organization: nil)
        uncat = create(:imports_uncategorized, parent: standards_import)
        pdf = create(:imports_pdf, parent: uncat)

        expect(pdf.organization).to be_blank
      end
    end
  end

  describe "#text" do
    it "converts pdf to text" do
      pdf = create(:imports_pdf)

      pdf_text = "Appendix A\n\n Welder (Industrial)\n(Competency based)\n\n"
      cleaned_text = pdf_text.gsub('\n', " ").gsub(/\s+/, " ").strip

      reader_mock = instance_double "PDF::Reader"
      allow(PDF::Reader).to receive(:new).and_return(reader_mock)
      allow(reader_mock).to receive(:pages).and_return([instance_double("PDF::Reader::Page", text: pdf_text)])

      expect(pdf.text).to eq cleaned_text
    end
  end
end
