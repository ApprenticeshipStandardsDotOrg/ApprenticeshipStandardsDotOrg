require "rails_helper"

RSpec.describe OccupationStandard, type: :model do
  it "has a valid factory" do
    occupation_standard = build(:occupation_standard)

    expect(occupation_standard).to be_valid
  end

  describe ".by_title" do
    it "returns records that match the argument in title" do
      first_occupation = create(:occupation_standard, title: "AAAAAA")
      create(:occupation_standard, title: "ZZZZZZ")

      expect(described_class.by_title("A")).to match_array([first_occupation])
    end

    it "returns all records if title not provided" do
      first_occupation = create(:occupation_standard, title: "AAAAAA")
      second_occupation = create(:occupation_standard, title: "ZZZZZZ")

      expect(described_class.by_title("")).to match_array([first_occupation, second_occupation])
    end

    it "returns records that match multiple words" do
      first_occupation = create(:occupation_standard, title: "Pipe Fitter")
      create(:occupation_standard, title: "Mechanic")

      expect(described_class.by_title("Pipe Fitter")).to match_array([first_occupation])
    end
  end

  describe ".by_rapids_code" do
    it "returns records that match the argument in rapids_code" do
      os1 = create(:occupation_standard, rapids_code: "1234")
      os2 = create(:occupation_standard, rapids_code: "1234CB")
      create(:occupation_standard, title: "HR", rapids_code: "123")

      expect(described_class.by_rapids_code("1234")).to contain_exactly(os1, os2)
    end

    it "returns all records if rapids_code not provided" do
      standards = create_pair(:occupation_standard, rapids_code: "1234")

      expect(described_class.by_rapids_code("")).to match_array standards
    end
  end

  describe "#sponsor_name" do
    it "returns organization name when it exists" do
      organization = build_stubbed(:organization, title: "Disney")
      occupation_standard = build(:occupation_standard, organization: organization)

      expect(occupation_standard.sponsor_name).to eq "Disney"
    end

    it "returns nil if no organization" do
      occupation_standard = build(:occupation_standard, organization: nil)

      expect(occupation_standard.sponsor_name).to be_nil
    end
  end

  describe "#source_file" do
    it "returns the linked source_file record" do
      create(:standards_import, :with_files)
      source_file = SourceFile.last
      data_import = create(:data_import, source_file: source_file)
      occupation_standard = build(:occupation_standard, data_imports: [data_import])

      expect(occupation_standard.source_file).to eq source_file
    end
  end

  describe "#compentencies_count" do
    it "sums competencies from all the work processes" do
      occupation_standard = create(:occupation_standard)
      wp1 = create(:work_process, occupation_standard: occupation_standard)
      wp2 = create(:work_process, occupation_standard: occupation_standard)
      create_list(:competency, 2, work_process: wp1)
      create_list(:competency, 1, work_process: wp2)
      create(:competency)

      expect(occupation_standard.competencies_count).to eq 3
    end
  end
end
