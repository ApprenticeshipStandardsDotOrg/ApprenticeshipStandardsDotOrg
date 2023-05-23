require "rails_helper"

RSpec.describe OccupationStandard, type: :model do
  it "has a valid factory" do
    occupation_standard = build(:occupation_standard)

    expect(occupation_standard).to be_valid
  end

  it "requires either registration agency or national_standard_type" do
    ra = build_stubbed(:registration_agency)
    occupation_standard = build(:occupation_standard, registration_agency: ra, national_standard_type: nil)

    expect(occupation_standard).to be_valid

    occupation_standard = build(:occupation_standard, registration_agency: nil, national_standard_type: :program_standard)

    expect(occupation_standard).to be_valid

    occupation_standard = build(:occupation_standard, registration_agency: nil, national_standard_type: nil)

    expect(occupation_standard).to_not be_valid
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

  describe ".by_onet_code" do
    it "returns records that match the argument in onet_code" do
      os1 = create(:occupation_standard, onet_code: "12.3456")
      os2 = create(:occupation_standard, onet_code: "12.34567")
      create(:occupation_standard, title: "HR", onet_code: "12.3")

      expect(described_class.by_onet_code("12.3456")).to contain_exactly(os1, os2)
    end

    it "returns all records if onet_code not provided" do
      standards = create_pair(:occupation_standard, onet_code: "12.345")

      expect(described_class.by_onet_code("")).to match_array standards
    end
  end

  describe ".by_state_id" do
    it "returns records that have a registration agency for that state" do
      ca = create(:state)
      wa = create(:state)
      ra_ca = create(:registration_agency, state: ca)
      ra_wa = create(:registration_agency, state: wa)
      os1 = create(:occupation_standard, registration_agency: ra_ca)
      os2 = create(:occupation_standard, registration_agency: ra_ca)
      create(:occupation_standard, registration_agency: ra_wa)

      expect(described_class.by_state_id(ca.id)).to contain_exactly(os1, os2)
    end

    it "returns all records if state_id not provided" do
      standards = create_pair(:occupation_standard)

      expect(described_class.by_state_id("")).to match_array standards
    end
  end

  describe ".by_national_standard_type" do
    it "returns records that match any of the national_standard_types passed" do
      os1 = create(:occupation_standard, :program_standard)
      os2 = create(:occupation_standard, :guideline_standard)
      create(:occupation_standard, :occupational_framework)

      expect(described_class.by_national_standard_type(%w[program_standard guideline_standard])).to contain_exactly(os1, os2)
    end

    it "can match on a string national_standard_type passed" do
      os1 = create(:occupation_standard, :program_standard)
      os2 = create(:occupation_standard, :program_standard)
      create(:occupation_standard, :occupational_framework)

      expect(described_class.by_national_standard_type("program_standard")).to contain_exactly(os1, os2)
    end

    it "if only occupational_framework passed as string, returns Urban Institute standards only" do
      org = create(:organization, title: "Urban Institute")
      os1 = create(:occupation_standard, :occupational_framework, organization: org)
      create(:occupation_standard, :occupational_framework)
      create(:occupation_standard, :program_standard)

      expect(described_class.by_national_standard_type("occupational_framework")).to contain_exactly(os1)
    end

    it "if only occupational_framework passed as array, returns Urban Institute standards only" do
      org = create(:organization, title: "Urban Institute")
      os1 = create(:occupation_standard, :occupational_framework, organization: org)
      create(:occupation_standard, :occupational_framework)
      create(:occupation_standard, :program_standard)

      expect(described_class.by_national_standard_type(%w[occupational_framework])).to contain_exactly(os1)
    end

    it "never includes non-Urban occupational_framework standards" do
      org = create(:organization, title: "Urban Institute")
      os1 = create(:occupation_standard, :occupational_framework, organization: org)
      os2 = create(:occupation_standard, :program_standard)
      create(:occupation_standard, :occupational_framework)

      expect(described_class.by_national_standard_type(%w[program_standard occupational_framework])).to contain_exactly(os1, os2)
    end

    it "returns all records if empty string provided" do
      standards = create_pair(:occupation_standard, :program_standard)

      expect(described_class.by_onet_code("")).to match_array standards
    end

    it "returns all records if empty array provided" do
      standards = create_pair(:occupation_standard, :program_standard)

      expect(described_class.by_onet_code([])).to match_array standards
    end
  end

  describe ".by_ojt_type" do
    it "returns records that match any of the ojt_types passed" do
      os1 = create(:occupation_standard, :hybrid)
      os2 = create(:occupation_standard, :time)
      create(:occupation_standard, :competency)

      expect(described_class.by_ojt_type(%w[time hybrid])).to contain_exactly(os1, os2)
    end

    it "can match on a string ojt_type passed" do
      os1 = create(:occupation_standard, :hybrid)
      os2 = create(:occupation_standard, :hybrid)
      create(:occupation_standard, :competency)

      expect(described_class.by_ojt_type("hybrid")).to contain_exactly(os1, os2)
    end

    it "returns all records if empty string provided" do
      standards = create_pair(:occupation_standard)

      expect(described_class.by_onet_code("")).to match_array standards
    end

    it "returns all records if empty array provided" do
      standards = create_pair(:occupation_standard)

      expect(described_class.by_onet_code([])).to match_array standards
    end
  end

  describe ".industry_count" do
    it "returns count of standards with industry prefix" do
      create(:occupation_standard, onet_code: "49-1234")
      create(:occupation_standard, onet_code: "49-0987")
      create(:occupation_standard, onet_code: "39-0987")

      expect(described_class.industry_count("49")).to eq 2
      expect(described_class.industry_count(49)).to eq 2
    end
  end

  describe ".search", :elasticsearch do
    it "returns occupation standards that match the given query" do
      _mechanic = create(:occupation_standard, title: "Mechanic")
      medical_assistant = create(:occupation_standard, title: "Medical Assistant")
      sleep 1

      result = OccupationStandard.search("Assistant")

      expect(result.response["hits"]["hits"].length).to eq 1
      expect(result.response["hits"]["hits"].first["_id"]).to eq medical_assistant.id
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

    it "is 0 if standard is time-based" do
      occupation_standard = create(:occupation_standard, :time)
      wp = create(:work_process, occupation_standard: occupation_standard)
      create(:competency, work_process: wp)

      expect(occupation_standard.competencies_count).to eq 0
    end
  end

  describe "#rsi_hours" do
    it "returns rsi_hours_max if present" do
      occupation_standard = build(:occupation_standard, rsi_hours_max: 1000, rsi_hours_min: 500)

      expect(occupation_standard.rsi_hours).to eq 1000
    end

    it "returns rsi_hours_min if rsi_hours_max is not present" do
      occupation_standard = build(:occupation_standard, rsi_hours_max: nil, rsi_hours_min: 500)

      expect(occupation_standard.rsi_hours).to eq 500
    end

    it "returns nil if rsi_hours_max or rsi_hours_min are not present" do
      occupation_standard = build(:occupation_standard, rsi_hours_max: nil, rsi_hours_min: nil)

      expect(occupation_standard.rsi_hours).to eq nil
    end
  end

  describe "#ojt_hours" do
    it "returns ojt_hours_max if present" do
      occupation_standard = build(:occupation_standard, ojt_hours_max: 1000, ojt_hours_min: 500)

      expect(occupation_standard.ojt_hours).to eq 1000
    end

    it "returns ojt_hours_min if ojt_hours_max is not present" do
      occupation_standard = build(:occupation_standard, ojt_hours_max: nil, ojt_hours_min: 500)

      expect(occupation_standard.ojt_hours).to eq 500
    end

    it "returns nil if ojt_hours_max or ojt_hours_min are not present" do
      occupation_standard = build(:occupation_standard, ojt_hours_max: nil, ojt_hours_min: nil)

      expect(occupation_standard.ojt_hours).to eq nil
    end
  end

  describe "#work_processes_hours" do
    it "returns sum of maximum hours if available" do
      occupation_standard = create(:occupation_standard)
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: 1000, minimum_hours: 400)
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: 1000, minimum_hours: 400)

      expect(occupation_standard.work_processes_hours).to eq 2000
    end

    it "returns sum of minimum hours if maximum hours not available" do
      occupation_standard = create(:occupation_standard)
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: nil, minimum_hours: 400)
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: nil, minimum_hours: 400)

      expect(occupation_standard.work_processes_hours).to eq 800
    end

    it "returns 0 if maximum hours and minimum hours are not present" do
      occupation_standard = create(:occupation_standard)
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: nil, minimum_hours: nil)
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: nil, minimum_hours: nil)

      expect(occupation_standard.work_processes_hours).to eq 0
    end

    it "sums only one work process with the same title" do
      occupation_standard = create(:occupation_standard)
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: 1000, title: "Process A")
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: 1000, title: "Process A")
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: 1000, title: "Process B")

      expect(occupation_standard.work_processes_hours).to eq 2000
    end

    it "returns 0 for competency-based standard" do
      occupation_standard = create(:occupation_standard, :competency)
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: 1000, minimum_hours: 400)

      expect(occupation_standard.work_processes_hours).to eq 0
    end
  end

  describe "#related_instructions_hours" do
    it "returns 0 if no related instructions available" do
      occupation_standard = build(:occupation_standard)

      expect(occupation_standard.related_instructions_hours).to eq 0
    end

    it "returns 0 if related instructions does not have hours set" do
      occupation_standard = create(:occupation_standard)
      create(:related_instruction, hours: nil, occupation_standard: occupation_standard)

      expect(occupation_standard.related_instructions_hours).to eq 0
    end

    it "returns sum of related instructions hours" do
      occupation_standard = create(:occupation_standard)
      create(:related_instruction, hours: 100, occupation_standard: occupation_standard, sort_order: 1)
      create(:related_instruction, hours: 200, occupation_standard: occupation_standard, sort_order: 2)
      create(:related_instruction, hours: nil, occupation_standard: occupation_standard, sort_order: 3)

      expect(occupation_standard.related_instructions_hours).to eq 300
    end
  end

  describe "#similar_programs" do
    it "returns occupations that match the title regardless of capitalization" do
      occupation_standard = create(:occupation_standard, title: "Human Resource Specialist")
      similar_program1 = create(:occupation_standard, title: "HUMAN RESOURCE SPECIALIST")
      similar_program2 = create(:occupation_standard, title: "human resource specialist")
      create(:occupation_standard, title: "Mechanic")

      expect(occupation_standard.similar_programs.pluck(:id)).to match_array [similar_program1.id, similar_program2.id]
    end

    it "returns up to MAX_SIMILAR_PROGRAMS_TO_DISPLAY occupations" do
      stub_const("OccupationStandard::MAX_SIMILAR_PROGRAMS_TO_DISPLAY", 1)
      occupation_standard = create(:occupation_standard, title: "Human Resource Specialist")
      create_list(:occupation_standard, 2, title: "Human Resource Specialist")

      expect(occupation_standard.similar_programs.count).to eq OccupationStandard::MAX_SIMILAR_PROGRAMS_TO_DISPLAY
    end

    it "excludes itself" do
      occupation_standard = create(:occupation_standard, title: "Human Resource Specialist")

      expect(occupation_standard.similar_programs).to be_empty
    end
  end

  describe "#ojt_type_display" do
    it "returns the ojt_type field titleized" do
      occupation_standard = build(:occupation_standard, ojt_type: "competency")

      expect(occupation_standard.ojt_type_display).to eq "Competency"
    end

    it "returns nil when ojt_type is nil" do
      occupation_standard = build(:occupation_standard, ojt_type: nil)

      expect(occupation_standard.ojt_type_display).to eq nil
    end
  end

  describe "#show_national_occupational_framework_badge?" do
    context "when occupation is part of national occupational framework" do
      it "returns true if organization is Urban Institute" do
        organization = Organization.urban_institute || create(:organization, title: "Urban Institute")
        occupation_standard = build(
          :occupation_standard,
          :occupational_framework,
          organization: organization
        )

        expect(occupation_standard.show_national_occupational_framework_badge?).to be true
      end

      it "returns false for any other organization" do
        Organization.urban_institute || create(:organization, title: "Urban Institute")
        organization = create(:organization, title: "Another Organization")
        occupation_standard = build(
          :occupation_standard,
          :occupational_framework,
          organization: organization
        )

        expect(occupation_standard.show_national_occupational_framework_badge?).to be false
      end

      it "returns false if organization is nil" do
        Organization.urban_institute || create(:organization, title: "Urban Institute")

        occupation_standard = build(
          :occupation_standard,
          :occupational_framework,
          organization: nil
        )

        expect(occupation_standard.show_national_occupational_framework_badge?).to be false
      end
    end
  end

  describe "#related_instructions_human_format_hours" do
    it "returns the related instructions hours formatted with precision 2 for significant digits" do
      occupation_standard = build(:occupation_standard)
      allow(occupation_standard).to receive(:related_instructions_hours).and_return(144)

      expect(occupation_standard.related_instructions_hours_in_human_format).to eq "140"
    end
  end

  describe "#work_processes_hours_in_human_format" do
    it "returns the work processes hours formatted with precision 2 for significant digits" do
      occupation_standard = build(:occupation_standard)
      allow(occupation_standard).to receive(:work_processes_hours).and_return(155)

      expect(occupation_standard.work_processes_hours_in_human_format).to eq "160"
    end
  end
end
