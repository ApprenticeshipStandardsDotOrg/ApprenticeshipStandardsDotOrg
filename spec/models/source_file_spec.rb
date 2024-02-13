require "rails_helper"

RSpec.describe SourceFile, type: :model do
  it "has a valid factory" do
    source_file = build(:source_file)

    expect(source_file).to be_valid
  end

  it "factory does not create an extra source file when saved" do
    source_file = create(:source_file)

    expect(source_file).to be_persisted
    expect(SourceFile.count).to eq 1
  end

  it "saves metadata as JSON when updating the record" do
    source_file = build(:source_file)

    source_file.metadata = "{\"date\":\"03/29/2023\"}"
    source_file.save

    expect(source_file.reload.metadata).to eq({"date" => "03/29/2023"})
  end

  describe ".recently_redacted" do
    it "returns records created the day before by default" do
      travel_to(Time.zone.local(2023, 6, 15)) do
        recent_records = [
          create(:source_file, redacted_at: Time.zone.local(2023, 6, 14)),
          create(:source_file, redacted_at: Time.zone.local(2023, 6, 14, 23, 59, 59))
        ]
        create(:source_file, redacted_at: Time.zone.local(2023, 6, 13, 23, 59, 59))

        expect(described_class.recently_redacted).to match_array recent_records
      end
    end

    it "returns records within the passed start and end time" do
      recent_records = [
        create(:source_file, redacted_at: Time.zone.local(2022, 6, 14)),
        create(:source_file, redacted_at: Time.zone.local(2022, 6, 14, 22, 59, 59))
      ]
      create(:source_file, redacted_at: Time.zone.local(2022, 6, 14, 23, 59, 59))

      start_time = Time.zone.local(2022, 6, 14)
      end_time = Time.zone.local(2022, 6, 14, 23)
      expect(described_class.recently_redacted(start_time: start_time, end_time: end_time)).to match_array recent_records
    end
  end

  describe ".pdf_attachment" do
    it "returns only source file with pdf as attachment" do
      create(:source_file, :docx)
      source_file_with_pdf_attachment = create(:source_file, :pdf)

      expect(described_class.pdf_attachment).to match_array [source_file_with_pdf_attachment]
    end
  end

  describe ".docx_attachment" do
    it "includes only source files with docx attachments" do
      _pdf = create(:source_file, :pdf)
      docx = create(:source_file, :docx)

      result = described_class.docx_attachment.pluck(:id)

      expect(result).to eql([docx.id])
    end
  end

  describe ".not_redacted" do
    it "returns only source file without redacted source file" do
      create(:source_file, :with_redacted_source_file)
      source_file_without_redacted_source_file = create(:source_file, :without_redacted_source_file)

      expect(described_class.not_redacted).to match_array [source_file_without_redacted_source_file]
    end
  end

  describe ".ready_for_redaction" do
    it "returns only source files without attachment, completed and pdf files" do
      source_file_with_all_conditions = create(:source_file,
        :pdf,
        :without_redacted_source_file,
        :completed)

      _source_file_not_complete = create(:source_file,
        :pdf,
        :without_redacted_source_file,
        :pending)

      _source_file_with_docx_attachment = create(:source_file,
        :docx,
        :without_redacted_source_file,
        :completed)

      _source_file_with_redacted_source_file = create(:source_file,
        :pdf,
        :with_redacted_source_file,
        :completed)

      expect(described_class.ready_for_redaction).to match_array [source_file_with_all_conditions]
    end
  end

  describe ".not_archived" do
    it "returns records which don't have an archived status" do
      _archived = create(:source_file, status: "archived")
      pending = create(:source_file, status: "pending")

      expect(described_class.not_archived.pluck(:id)).to eql([pending.id])
    end
  end

  describe ".already_redacted" do
    it "returns only source files that are already redacted" do
      source_file_with_redacted_source_file = create(:source_file, :with_redacted_source_file)
      create(:source_file, :without_redacted_source_file)

      expect(described_class.already_redacted).to match_array [source_file_with_redacted_source_file]
    end
  end

  describe "#convert_doc_file_to_pdf" do
    it "calls DocToPdfConverter job on create if docx file" do
      expect(DocToPdfConverterJob).to receive(:perform_later)

      create(:source_file, :docx)
    end

    it "does not call DocToPdfConverter job on create if not docx file" do
      expect(DocToPdfConverterJob).to_not receive(:perform_later)

      create(:source_file, :pdf)
    end
  end

  describe "#associated_occupation_standards" do
    it "returns unique occupation standards" do
      source_file = create(:source_file)
      data_import = create(:data_import, source_file: source_file)
      occupation_standard = data_import.occupation_standard
      create(:data_import, source_file: source_file, occupation_standard: occupation_standard)

      expect(source_file.associated_occupation_standards).to eq [occupation_standard]
    end
  end

  describe "#needs_courtesy_notification?" do
    it "is false if status is pending" do
      source_file = build(:source_file, :pending)

      expect(source_file.needs_courtesy_notification?).to be false
    end

    it "is false if status is needs_support" do
      source_file = build(:source_file, :needs_support)

      expect(source_file.needs_courtesy_notification?).to be false
    end

    it "is false if status is completed and courtesy_notification is completed" do
      source_file = build(:source_file, :completed, courtesy_notification: :completed)

      expect(source_file.needs_courtesy_notification?).to be false
    end

    it "is false if status is completed and courtesy_notification is not_required" do
      source_file = build(:source_file, :completed, courtesy_notification: :not_required)

      expect(source_file.needs_courtesy_notification?).to be false
    end

    it "is true if status is completed and courtesy_notification is pending" do
      source_file = build(:source_file, :completed, courtesy_notification: :pending)

      expect(source_file.needs_courtesy_notification?).to be true
    end
  end

  describe "#organization" do
    it "returns organization from standards_import association" do
      create(:standards_import, :with_files, organization: "Pipe Fitters R Us")
      source_file = SourceFile.last

      expect(source_file.organization).to eq "Pipe Fitters R Us"
    end
  end

  describe "#notes" do
    it "returns notes from standards_import association" do
      create(:standards_import, :with_files, notes: "From scraper job")
      source_file = SourceFile.last

      expect(source_file.notes).to eq "From scraper job"
    end
  end

  describe "#claimed?" do
    it "returns true if there is an assignee" do
      admin = build_stubbed(:admin)
      source_file = build_stubbed(:source_file, assignee: admin)

      expect(source_file).to be_claimed
    end

    it "returns false if there is no assignee" do
      source_file = build_stubbed(:source_file, assignee: nil)

      expect(source_file).to_not be_claimed
    end
  end

  describe "#pdf?" do
    it "returns true when attachment is a pdf file" do
      source_file = create(:source_file, :pdf)
      expect(source_file.pdf?).to be(true)
    end

    it "returns false when attachment is docx" do
      source_file = create(:source_file, :docx)
      expect(source_file.pdf?).to be(false)
    end
  end

  describe "#docx?" do
    it "is true if the content_type is docx" do
      source_file = create(:source_file, :docx)
      expect(source_file.docx?).to be(true)
    end

    it "is false if the content_type is not docx" do
      source_file = create(:source_file, :pdf)
      expect(source_file.docx?).to be(false)
    end
  end

  describe "#redacted_source_file_url" do
    it "returns nil if file not present" do
      source_file = build(:source_file, redacted_source_file: nil)

      expect(source_file.redacted_source_file_url).to be nil
    end

    it "returns file url if file present", :url_generation do
      source_file = build(:source_file, redacted_source_file: fixture_file_upload("pixel1x1.jpg", "image/jpeg"))

      expect(source_file.redacted_source_file_url).to be_present
    end
  end

  describe "#file_for_redaction" do
    it "returns redacted_source_file if present" do
      source_file = build(:source_file, redacted_source_file: fixture_file_upload("pixel1x1.jpg", "image/jpeg"))

      expect(source_file.file_for_redaction).to eq source_file.redacted_source_file
    end

    it "returns active_storage_attachment if redacted_source_file is not present" do
      source_file = create(:source_file, redacted_source_file: nil)

      expect(source_file.file_for_redaction).to eq source_file.active_storage_attachment
    end
  end
end
