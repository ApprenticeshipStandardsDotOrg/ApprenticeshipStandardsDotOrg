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
end
