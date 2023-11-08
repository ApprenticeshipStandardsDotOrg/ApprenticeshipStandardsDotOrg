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

  describe ".by_state_abbreviation" do
    it "returns records that have a registration agency for that state abbreviation" do
      california = create(:state, abbreviation: "CA")
      washington = create(:state, abbreviation: "WA")
      agency_california = create(:registration_agency, state: california)
      agency_washington = create(:registration_agency, state: washington)
      standard_1 = create(:occupation_standard, registration_agency: agency_california)
      standard_2 = create(:occupation_standard, registration_agency: agency_california)
      create(:occupation_standard, registration_agency: agency_washington)
      create(:occupation_standard, registration_agency: agency_washington)

      expect(described_class.by_state_abbreviation(california.abbreviation)).to contain_exactly(standard_1, standard_2)
    end

    it "returns all records if state_abbreviation not provided" do
      standards = create_pair(:occupation_standard)

      expect(described_class.by_state_abbreviation("")).to match_array standards
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

    it "if only occupational_framework passed as symbol, returns Urban Institute standards only" do
      org = create(:organization, title: "Urban Institute")
      os1 = create(:occupation_standard, :occupational_framework, organization: org)
      create(:occupation_standard, :occupational_framework)
      create(:occupation_standard, :program_standard)

      expect(described_class.by_national_standard_type(:occupational_framework)).to contain_exactly(os1)
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

      expect(occupation_standard.reload.work_processes_hours).to eq 2000
    end

    it "returns sum of minimum hours if maximum hours not available" do
      occupation_standard = create(:occupation_standard)
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: nil, minimum_hours: 400)
      create(:work_process, occupation_standard: occupation_standard, maximum_hours: nil, minimum_hours: 400)

      expect(occupation_standard.reload.work_processes_hours).to eq 800
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

      expect(occupation_standard.reload.work_processes_hours).to eq 2000
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
    context "with the similar_programs_elasticsearch flag enabled" do
      it "returns from SimilarOccupationStandards.similar_to" do
        stub_feature_flag(:similar_programs_elasticsearch, true)

        allow(SimilarOccupationStandards).to receive(:similar_to).and_return([])

        occupation_standard = build(:occupation_standard)

        expect(occupation_standard.similar_programs).to eq []
      end
    end

    context "with the similar_programs_elasticsearch flag disabled" do
      before do
        stub_feature_flag(:similar_programs_elasticsearch, false)
      end

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
  end

  describe "#duplicates" do
    context "with the similar_programs_elasticsearch flag enabled" do
      it "returns from OccupationStandard#inner_hits excluding self" do
        stub_feature_flag(:similar_programs_elasticsearch, true)

        occupation_standard = create(:occupation_standard)
        duplicate_inner_hit = create(:inner_hit, id: "1", title: "Duplicate")
        occupation_standard_inner_hit = create(:inner_hit, id: occupation_standard.id, title: occupation_standard.title)
        duplicates = [duplicate_inner_hit, occupation_standard_inner_hit]

        occupation_standard.inner_hits = duplicates

        expect(occupation_standard.duplicates).to match_array [duplicate_inner_hit]
      end
    end

    context "with the similar_programs_elasticsearch flag disabled" do
      it "returns occupations that match the title regardless of capitalization" do
        stub_feature_flag(:similar_programs_elasticsearch, false)

        occupation_standard = create(:occupation_standard, title: "Human Resource Specialist")
        similar_program1 = create(:occupation_standard, title: "HUMAN RESOURCE SPECIALIST")
        similar_program2 = create(:occupation_standard, title: "human resource specialist")
        create(:occupation_standard, title: "Mechanic")

        expect(occupation_standard.duplicates.pluck(:id)).to match_array [similar_program1.id, similar_program2.id]
      end

      it "returns up to MAX_SIMILAR_PROGRAMS_TO_DISPLAY occupations" do
        stub_feature_flag(:similar_programs_elasticsearch, false)

        stub_const("OccupationStandard::MAX_SIMILAR_PROGRAMS_TO_DISPLAY", 1)
        occupation_standard = create(:occupation_standard, title: "Human Resource Specialist")
        create_list(:occupation_standard, 2, title: "Human Resource Specialist")

        expect(occupation_standard.duplicates.count).to eq OccupationStandard::MAX_SIMILAR_PROGRAMS_TO_DISPLAY
      end

      it "excludes itself" do
        stub_feature_flag(:similar_programs_elasticsearch, false)
        occupation_standard = create(:occupation_standard, title: "Human Resource Specialist")

        expect(occupation_standard.duplicates).to be_empty
      end
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

  describe "#public_document?" do
    it "returns true if OccupationStandard#public_document flag is true" do
      occupation_standard = create(:occupation_standard, :with_data_import)
      allow_any_instance_of(SourceFile).to receive(:public_document).and_return(true)

      expect(occupation_standard.public_document?).to be true
    end

    it "returns true if associated standard import is public document regardless of public_document flag" do
      occupation_standard = create(:occupation_standard, :with_data_import)
      allow_any_instance_of(SourceFile).to receive(:public_document).and_return(false)
      allow_any_instance_of(StandardsImport).to receive(:public_document).and_return(true)

      expect(occupation_standard.public_document?).to be true
    end
  end

  describe "#hours_meet_occupation_requirements?" do
    it "returns true if work_process hours match occupation hours" do
      occupation = create(:occupation, time_based_hours: 1000)
      occupation_standard = create(:occupation_standard, occupation: occupation)
      create(:work_process, maximum_hours: 2000, occupation_standard: occupation_standard)

      occupation_standard.reload

      expect(occupation_standard.hours_meet_occupation_requirements?).to be true
    end

    it "returns false if work_process hours do not match occupation hours" do
      occupation = create(:occupation, time_based_hours: 2000)
      occupation_standard = create(:occupation_standard, occupation: occupation)
      create(:work_process, maximum_hours: 1000, occupation_standard: occupation_standard)

      expect(occupation_standard.hours_meet_occupation_requirements?).to be false
    end

    it "returns true if there is no associated occupation" do
      occupation_standard = create(:occupation_standard, occupation_id: nil)
      create(:work_process, maximum_hours: 2000, occupation_standard: occupation_standard)

      expect(occupation_standard.hours_meet_occupation_requirements?).to be true
      expect(occupation_standard.occupation).to be nil
    end
  end

  describe "#state_abbreviation" do
    it "returns nil when registration agency is not associated to an state" do
      registration_agency = create(:registration_agency, state: nil)
      occupation_standard = create(:occupation_standard, registration_agency: registration_agency)

      expect(occupation_standard.state_abbreviation).to be_nil
    end

    it "returns state abbreviation when registration agency has state" do
      state = create(:state, name: "California", abbreviation: "CA")
      registration_agency = create(:registration_agency, state: state)
      occupation_standard = create(:occupation_standard, registration_agency: registration_agency)

      expect(occupation_standard.state_abbreviation).to eq "CA"
    end
  end

  describe "#state_id" do
    it "returns nil when registration agency is not associated to an state" do
      registration_agency = create(:registration_agency, state: nil)
      occupation_standard = create(:occupation_standard, registration_agency: registration_agency)

      expect(occupation_standard.state_id).to be_nil
    end

    it "returns state id when registration agency has state" do
      state = create(:state)
      registration_agency = create(:registration_agency, state: state)
      occupation_standard = create(:occupation_standard, registration_agency: registration_agency)

      expect(occupation_standard.state_id).to eq state.id
    end
  end

  describe "#industry_name" do
    it "returns nil when occupation standard is not linked to an industry" do
      occupation_standard = build(:occupation_standard, industry: nil)

      expect(occupation_standard.industry_name).to be_nil
    end

    it "returns industry name when occupation standard is linked to an industry" do
      industry = build_stubbed(:industry, name: "Legal Occupations")
      occupation_standard = build(:occupation_standard, industry: industry)

      expect(occupation_standard.industry_name).to eq "Legal Occupations"
    end
  end

  describe "#national_standard_type_with_adjustment" do
    it "returns nil if no national_standard_type" do
      occupation_standard = build(:occupation_standard, national_standard_type: nil)

      expect(occupation_standard.national_standard_type_with_adjustment).to be_nil
    end

    it "returns program_standard if program_standard" do
      occupation_standard = build(:occupation_standard, :program_standard)

      expect(occupation_standard.national_standard_type_with_adjustment).to eq "program_standard"
    end

    it "returns guideline_standard if guideline_standard" do
      occupation_standard = build(:occupation_standard, :guideline_standard)

      expect(occupation_standard.national_standard_type_with_adjustment).to eq "guideline_standard"
    end

    it "returns occupational_framework if occupational_framework and organization is Urban Institute" do
      organization = create(:organization, title: "Urban Institute")
      occupation_standard = create(:occupation_standard, :occupational_framework, organization: organization)

      expect(occupation_standard.national_standard_type_with_adjustment).to eq "occupational_framework"
    end

    it "returns nil if occupational_framework and organization is not Urban Institute" do
      organization = create(:organization, title: "Some Institute")
      occupation_standard = create(:occupation_standard, :occupational_framework, organization: organization)

      expect(occupation_standard.national_standard_type_with_adjustment).to be_nil
    end
  end

  describe "#related_job_titles" do
    it "returns an empty array if no onet_code" do
      os = build(:occupation_standard, onet_code: nil)

      expect(os.related_job_titles).to be_empty
    end

    it "returns an empty array if onet_code but onet has no related_job titles" do
      build_stubbed(:onet, code: "1234.56", related_job_titles: [])
      os = build(:occupation_standard, onet_code: "1234.56")

      expect(os.related_job_titles).to be_empty
    end

    it "returns onet related_jobs titles if has onet_code" do
      create(:onet, code: "1234.56", related_job_titles: ["Engineer", "Developer"])
      os = build(:occupation_standard, onet_code: "1234.56")

      expect(os.related_job_titles).to contain_exactly("Engineer", "Developer")
    end
  end

  describe "#headline" do
    context "when time-based standard" do
      context "when state exists" do
        it "concatenates state, type, title, work process hours, work process titles" do
          state = create(:state)
          agency = create(:registration_agency, state: state)
          occupation_standard = create(:occupation_standard, :time, registration_agency: agency, title: "Pipe Fitter")
          create(:work_process, occupation_standard: occupation_standard, sort_order: 2, title: "fox jumps over", maximum_hours: 100)
          create(:work_process, occupation_standard: occupation_standard, sort_order: 1, title: "The quick brown", maximum_hours: 200)
          create(:work_process, occupation_standard: occupation_standard, sort_order: 3, title: "the lazy dog", maximum_hours: 400)

          occupation_standard.reload

          expect(occupation_standard.headline).to eq Digest::SHA2.hexdigest(
            "#{state.abbreviation}-time-pipe-fitter-700-the-quick-brown-fox-jumps-over-the-lazy-dog"
          )
        end
      end

      context "when state does not exist" do
        it "concatenates type, title, work process hours, work process titles" do
          agency = create(:registration_agency, state: nil)
          occupation_standard = create(:occupation_standard, :time, registration_agency: agency, title: "Pipe Fitter")
          create(:work_process, occupation_standard: occupation_standard, sort_order: 2, title: "fox jumps over", maximum_hours: 100)
          create(:work_process, occupation_standard: occupation_standard, sort_order: 1, title: "The quick brown", maximum_hours: 200)
          create(:work_process, occupation_standard: occupation_standard, sort_order: 3, title: "the lazy dog", maximum_hours: 400)

          occupation_standard.reload

          expect(occupation_standard.headline).to eq Digest::SHA2.hexdigest(
            "time-pipe-fitter-700-the-quick-brown-fox-jumps-over-the-lazy-dog"
          )
        end
      end
    end

    context "when competency-based standard" do
      context "when state exists" do
        it "concatenates state, type, title, skill names" do
          state = create(:state)
          agency = create(:registration_agency, state: state)
          occupation_standard = create(:occupation_standard, :competency, registration_agency: agency, title: "Pipe Fitter")
          wp1 = create(:work_process, occupation_standard: occupation_standard, sort_order: 2)
          wp2 = create(:work_process, occupation_standard: occupation_standard, sort_order: 1)
          create(:competency, work_process: wp1, sort_order: 1, title: "jumps over")
          create(:competency, work_process: wp1, sort_order: 2, title: "the lazy dog")
          create(:competency, work_process: wp2, sort_order: 2, title: "brown fox")
          create(:competency, work_process: wp2, sort_order: 1, title: "The quick")

          occupation_standard.reload

          expect(occupation_standard.headline).to eq Digest::SHA2.hexdigest(
            "#{state.abbreviation}-competency-pipe-fitter-0-the-quick-brown-fox-jumps-over-the-lazy-dog"
          )
        end
      end

      context "when state does not exist" do
        it "concatenates type, title, skill names" do
          agency = create(:registration_agency, state: nil)
          occupation_standard = create(:occupation_standard, :competency, registration_agency: agency, title: "Pipe Fitter")
          wp1 = create(:work_process, occupation_standard: occupation_standard, sort_order: 2)
          wp2 = create(:work_process, occupation_standard: occupation_standard, sort_order: 1)
          create(:competency, work_process: wp1, sort_order: 1, title: "jumps over")
          create(:competency, work_process: wp1, sort_order: 2, title: "the lazy dog")
          create(:competency, work_process: wp2, sort_order: 2, title: "brown fox")
          create(:competency, work_process: wp2, sort_order: 1, title: "The quick")

          occupation_standard.reload

          expect(occupation_standard.headline).to eq Digest::SHA2.hexdigest(
            "competency-pipe-fitter-0-the-quick-brown-fox-jumps-over-the-lazy-dog"
          )
        end
      end
    end

    context "when hybrid standard" do
      context "when state exists" do
        it "concatenates state, type, title, work process hours, skill names, work process titles" do
          state = create(:state)
          agency = create(:registration_agency, state: state)
          occupation_standard = create(:occupation_standard, :hybrid, registration_agency: agency, title: "Pipe Fitter")
          wp1 = create(:work_process, title: "wp1", occupation_standard: occupation_standard, sort_order: 2, maximum_hours: 200)
          wp2 = create(:work_process, title: "wp2", occupation_standard: occupation_standard, sort_order: 1, maximum_hours: 500)
          create(:competency, work_process: wp1, sort_order: 1, title: "jumps over")
          create(:competency, work_process: wp1, sort_order: 2, title: "the lazy dog")
          create(:competency, work_process: wp2, sort_order: 2, title: "brown fox")
          create(:competency, work_process: wp2, sort_order: 1, title: "The quick")

          occupation_standard.reload

          expect(occupation_standard.headline).to eq Digest::SHA2.hexdigest(
            "#{state.abbreviation}-hybrid-pipe-fitter-700-the-quick-brown-fox-jumps-over-the-lazy-dog-wp2-wp1"
          )
        end
      end

      context "when state does not exist" do
        it "concatenates type, title, work process hours, skill names, work process titles" do
          agency = create(:registration_agency, state: nil)
          occupation_standard = create(:occupation_standard, :hybrid, registration_agency: agency, title: "Pipe Fitter")
          wp1 = create(:work_process, title: "wp1", occupation_standard: occupation_standard, sort_order: 2, maximum_hours: 200)
          wp2 = create(:work_process, title: "wp2", occupation_standard: occupation_standard, sort_order: 1, maximum_hours: 500)
          create(:competency, work_process: wp1, sort_order: 1, title: "jumps over")
          create(:competency, work_process: wp1, sort_order: 2, title: "the lazy dog")
          create(:competency, work_process: wp2, sort_order: 2, title: "brown fox")
          create(:competency, work_process: wp2, sort_order: 1, title: "The quick")

          occupation_standard.reload

          expect(occupation_standard.headline).to eq Digest::SHA2.hexdigest(
            "hybrid-pipe-fitter-700-the-quick-brown-fox-jumps-over-the-lazy-dog-wp2-wp1"
          )
        end
      end
    end
  end

  describe "#clean_onet_code" do
    it "returns the onet code with symbols in the correct place if they are wrong" do
      occupation_standard = build(:occupation_standard, onet_code: "31­1011.00")

      expect(occupation_standard.clean_onet_code).to eq "31-1011.00"
    end

    it "returns the onet code with any extra spaces removed" do
      occupation_standard = build(:occupation_standard, onet_code: "17-3024.00   ")

      expect(occupation_standard.clean_onet_code).to eq "17-3024.00"
    end

    it "returns the onet code with any letters removed" do
      occupation_standard = build(:occupation_standard, onet_code: "39-9011.00T")

      expect(occupation_standard.clean_onet_code).to eq "39-9011.00"
    end

    it "returns the original onet code if the onet code is too short" do
      occupation_standard = build(:occupation_standard, onet_code: "51-4011")

      expect(occupation_standard.clean_onet_code).to eq "51-4011"
    end

    it "returns the original onet code if it is already in the expected format" do
      occupation_standard = build(:occupation_standard, onet_code: "12-3456.07")

      expect(occupation_standard.clean_onet_code).to eq "12-3456.07"
    end

    it "returns nil if the onet code is all letters with no numbers" do
      occupation_standard = build(:occupation_standard, onet_code: "onet")

      expect(occupation_standard.clean_onet_code).to be_nil
    end

    it "returns nil if the onet code is already nil" do
      occupation_standard = build(:occupation_standard, onet_code: nil)

      expect(occupation_standard.clean_onet_code).to be_nil
    end

    it "does not modify the onet_code column" do
      occupation_standard = create(:occupation_standard, onet_code: "17-3024.00   ")

      expect do
        occupation_standard.clean_onet_code
        occupation_standard.reload
      end.not_to change(occupation_standard, :onet_code)
    end
  end

  describe "#related_onet_code_versions" do
    it "is empty if onet_code is nil" do
      occupation_standard = build(:occupation_standard, onet_code: nil)

      expect(occupation_standard.related_onet_code_versions).to be_empty
    end

    it "is empty if onet does not exist for onet_code" do
      occupation_standard = build(:occupation_standard, onet_code: "12-3456.00")

      expect(occupation_standard.related_onet_code_versions).to be_empty
    end

    it "returns all versions of onet_code if onet exists" do
      onet = build(:onet, code: "12-3456.00")
      occupation_standard = build(:occupation_standard, onet_code: "12-3456.00")
      allow(Onet).to receive(:find_by).with(code: "12-3456.00").and_return(onet)
      allow(onet).to receive(:all_versions).and_return(["12.3456.00", "12.3456"])

      expect(occupation_standard.related_onet_code_versions).to eq(["12.3456.00", "12.3456"])
    end
  end
end
