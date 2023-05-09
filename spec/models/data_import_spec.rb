require "rails_helper"

RSpec.describe DataImport, type: :model do
  it "has a valid factory" do
    data_import = build(:data_import)

    expect(data_import).to be_valid
  end

  it "requires a file attachment" do
    data_import = build(:data_import, file: nil)

    expect(data_import).to_not be_valid
  end

  describe "#file_mime_type" do
    it "is valid with accepted content-type" do
      file = Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "occupation-standards-template.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      data_import = build(:data_import, file: file)

      expect(data_import).to be_valid
    end

    it "is invalid with non-accepted content-type" do
      file = Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.jpg"), "image/jpeg")
      data_import = build(:data_import, file: file)

      expect(data_import).to_not be_valid
    end
  end

  describe "#related_occupation_standard" do
    it "returns occupation standard linked to same source file with same name" do
      os = create(:occupation_standard, title: "HUMAN RESOURCE SPECIALIST")
      data_import1 = create(:data_import, occupation_standard: os)

      os_other = create(:occupation_standard, title: "NOT HUMAN RESOURCE SPECIALIST")
      _data_import2 = create(:data_import, occupation_standard: os_other, source_file: data_import1.source_file)

      data_import3 = create(:data_import, occupation_standard: nil, source_file: data_import1.source_file)


      expect(data_import3.related_occupation_standard("HUMAN RESOURCE SPECIALIST")).to eq os
    end
  end
end
