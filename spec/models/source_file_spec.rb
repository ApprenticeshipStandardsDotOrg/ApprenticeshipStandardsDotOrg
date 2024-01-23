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
      file = fixture_file_upload("pixel1x1.pdf", "application/pdf")
      create(:standards_import, files: [file])
      source_file = SourceFile.last

      expect(source_file.pdf?).to be true
    end

    it "returns false when attachment is an image" do
      file = fixture_file_upload("pixel1x1.jpg", "image/jpeg")
      create(:standards_import, files: [file])
      source_file = SourceFile.last

      expect(source_file.pdf?).to be false
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
      create(:source_file, :with_docx_attachment)
      source_file_with_pdf_attachment = create(:source_file, :with_pdf_attachment)

      expect(described_class.pdf_attachment).to match_array [source_file_with_pdf_attachment]
    end
  end
end
