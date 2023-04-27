require "rails_helper"

RSpec.describe OccupationStandard, type: :model do
  it "has a valid factory" do
    occupation_standard = build(:occupation_standard)

    expect(occupation_standard).to be_valid
  end

  describe "#rapids_code" do
    it "returns occupation rapids_code when occupation exists" do
      occupation = build_stubbed(:occupation, rapids_code: "abc")
      occupation_standard = build(:occupation_standard, occupation: occupation)

      expect(occupation_standard.rapids_code).to eq "abc"
    end

    it "returns own rapids_code when no occupation" do
      occupation_standard = build(:occupation_standard, occupation: nil, rapids_code: "def")

      expect(occupation_standard.rapids_code).to eq "def"
    end
  end

  describe "#onet_code" do
    it "returns occupation onet_code string when occupation and onet_code exists" do
      onet = build_stubbed(:onet, code: "abc")
      occupation = build_stubbed(:occupation, onet: onet)
      occupation_standard = build(:occupation_standard, occupation: occupation)

      expect(occupation_standard.onet_code).to eq "abc"
    end

    it "returns nil when occupation exists but onet_code does not" do
      occupation = build_stubbed(:occupation, onet: nil)
      occupation_standard = build(:occupation_standard, occupation: occupation)

      expect(occupation_standard.onet_code).to be_nil
    end

    it "returns own onet_code when no occupation" do
      occupation_standard = build(:occupation_standard, occupation: nil, onet_code: "123")

      expect(occupation_standard.onet_code).to eq "123"
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

  describe ".by_title" do
    it "returns records that match the argument in title" do
      first_occupation = create(:occupation_standard, title: "AAAAAA")
      create(:occupation_standard, title: "ZZZZZZ")

      expect(described_class.by_title("A").pluck(:id)).to match_array([first_occupation.id])
    end

    it "returns all records if title not provided" do
      first_occupation = create(:occupation_standard, title: "AAAAAA")
      second_occupation = create(:occupation_standard, title: "ZZZZZZ")

      expect(described_class.by_title("").pluck(:id)).to match_array([first_occupation.id, second_occupation.id])
    end
  end
end
