require "rails_helper"

RSpec.describe DataImport, type: :model do
  it "has a valid factory" do
    data_import = build(:data_import)

    expect(data_import).to be_valid
  end

  describe ".recent_uploads" do
    it "returns records created the day before by default" do
      travel_to(Time.zone.local(2023, 6, 15)) do
        recent_records = [
          create(:data_import, created_at: Time.zone.local(2023, 6, 14)),
          create(:data_import, created_at: Time.zone.local(2023, 6, 14, 23, 59, 59))
        ]
        create(:data_import, created_at: Time.zone.local(2023, 6, 13, 23, 59, 59))

        expect(described_class.recent_uploads).to match_array recent_records
      end
    end

    it "returns records within the passed start and end time" do
      recent_records = [
        create(:data_import, created_at: Time.zone.local(2022, 6, 14)),
        create(:data_import, created_at: Time.zone.local(2022, 6, 14, 22, 59, 59))
      ]
      create(:data_import, created_at: Time.zone.local(2022, 6, 14, 23, 59, 59))

      start_time = Time.zone.local(2022, 6, 14)
      end_time = Time.zone.local(2022, 6, 14, 23)
      expect(described_class.recent_uploads(start_time: start_time, end_time: end_time)).to match_array recent_records
    end
  end

  describe "#file_mime_type" do
    it "is valid with accepted content-type" do
      file = fixture_file_upload("occupation-standards-template.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      data_import = build(:data_import, file: file)

      expect(data_import).to be_valid
    end

    it "is invalid with non-accepted content-type" do
      file = fixture_file_upload("pixel1x1.jpg", "image/jpeg")
      data_import = build(:data_import, file: file)

      expect(data_import).to_not be_valid
    end
  end

  describe "#related_occupation_standard" do
    it "returns occupation standard linked to same import with same name" do
      initial_os = create(:occupation_standard, title: "NOT HUMAN RESOURCE SPECIALIST")
      pdf = create(:imports_pdf)
      _initial_data_import = create(:data_import, occupation_standard: initial_os, import: pdf)

      different_os_for_same_pdf = create(:occupation_standard, title: "HUMAN RESOURCE SPECIALIST")
      _data_import_with_some_errors = create(:data_import, occupation_standard: different_os_for_same_pdf, import: pdf)

      os_from_a_different_pdf = create(:occupation_standard, title: "HUMAN RESOURCE SPECIALIST")
      different_pdf = create(:imports_pdf)
      create(:data_import, occupation_standard: os_from_a_different_pdf, import: different_pdf)

      data_import_corrected = create(:data_import, occupation_standard: nil, import: pdf)

      expect(data_import_corrected.related_occupation_standard("HUMAN RESOURCE SPECIALIST")).to eq different_os_for_same_pdf
    end
  end

  describe "#to_text" do
    it "creates a new text representation if not present" do
      pdf = create(:imports_pdf)
      data_import = create(:data_import, import: pdf)

      expect(data_import.text_representation).to be_nil

      expect {
        expect(data_import.to_text).to eq "" # PDF for test does not have text
      }.to change(TextRepresentation, :count).by(1)

      expect(data_import.text_representation).to be_present
    end

    it "returns content from text representation when present" do
      pdf = create(:imports_pdf)
      data_import = create(:data_import, import: pdf)
      create(:text_representation, content: "PDF content", data_import: data_import)

      expect(data_import.text_representation).to be_present

      expect {
        expect(data_import.to_text).to eq "PDF content"
      }.not_to change(TextRepresentation, :count)
    end
  end
end
