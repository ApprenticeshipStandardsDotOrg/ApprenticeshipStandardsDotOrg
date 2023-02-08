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

  describe "#process_data_import" do
    it "calls job to process the file when record is created" do
      expect(ProcessDataImportJob).to receive(:perform_later).with(kind_of(DataImport))

      create(:data_import)
    end

    it "does not call job to process the file when record is updated" do
      data_import = create(:data_import)
      expect(ProcessDataImportJob).to_not receive(:perform_later)

      data_import.update!(description: "New description")
    end
  end
end
