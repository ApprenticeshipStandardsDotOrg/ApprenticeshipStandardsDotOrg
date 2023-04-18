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
end
