require "rails_helper"

RSpec.describe SourceFile, type: :model do
  it "has a valid factory" do
    source_file = build(:source_file)

    expect(source_file).to be_valid
  end

  it "saves metadata as JSON when updating the record" do
    si = create(:standards_import, :with_files)
    source_file = build(:source_file, active_storage_attachment_id: si.files.first.id)

    source_file.metadata = "{\"date\":\"03/29/2023\"}"
#    binding.break
    source_file.save

    expect(source_file.reload.metadata).to eq({"date" => "03/29/2023"})
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
      active_storage_attachment = build_stubbed(:active_storage_attachment, content_type: "application/pdf")
      source_file = build_stubbed(:source_file, active_storage_attachment: active_storage_attachment)

      expect(source_file.pdf?).to be true
    end

    it "returns false when attachment is an image" do
      active_storage_attachment = build_stubbed(:active_storage_attachment, content_type: "image/png")
      source_file = build(:source_file, active_storage_attachment: active_storage_attachment)

      expect(source_file.pdf?).to be false
    end

    it "returns false when attachment is not present" do
      source_file = build(:source_file, active_storage_attachment: nil)

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
      active_storage_attachment = build_stubbed(:active_storage_attachment, content_type: "image/png")
      source_file = build(:source_file,
        active_storage_attachment: active_storage_attachment,
        redacted_source_file: nil)

      expect(source_file.file_for_redaction).to eq source_file.active_storage_attachment
    end

    it "returns nil if no file present" do
      source_file = build(:source_file, active_storage_attachment: nil, redacted_source_file: nil)

      expect(source_file.file_for_redaction).to be nil
    end
  end
end
