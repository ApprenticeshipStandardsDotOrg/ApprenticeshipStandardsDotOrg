require "rails_helper"

RSpec.describe SourceFile, type: :model do
  it "has a valid factory" do
    source_file = build(:source_file)

    expect(source_file).to be_valid
  end

  it "saves metadata as JSON when updating the record" do
    source_file = build(:source_file)

    source_file.metadata = "{\"date\":\"03/29/2023\"}"
    source_file.save

    expect(source_file.metadata).to eq({"date" => "03/29/2023"})
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
      active_storage_attachment = build_stubbed(:active_storage_attachment, filename: "abc.pdf")
      source_file = build_stubbed(:source_file, active_storage_attachment: active_storage_attachment)

      expect(source_file.pdf?).to be true
    end

    it "returns false when attachment is an image" do
      active_storage_attachment = build_stubbed(:active_storage_attachment, filename: "abc.png")
      source_file = build(:source_file, active_storage_attachment: active_storage_attachment)

      expect(source_file.pdf?).to be false
    end

    it "returns false when attachment is not present" do
      source_file = build(:source_file, active_storage_attachment: nil)

      expect(source_file.pdf?).to be false
    end
  end
end
