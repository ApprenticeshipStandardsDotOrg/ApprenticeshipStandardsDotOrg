require "rails_helper"

RSpec.describe OccupationStandardQuery do
  context "when elasticsearch for search is not enabled" do
    before(:each) do |example|
      Flipper.disable(:use_elasticsearch_for_search)
    end

    it "allows searching occupation standards by title" do
      occupation_standard_for_mechanic = create(:occupation_standard, title: "Mechanic")
      create(:occupation_standard, title: "Pipe Fitter")
      params = {q: "Mechanic"}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to eq [occupation_standard_for_mechanic.id]
    end

    it "allows searching occupation standards by rapids code" do
      os1 = create(:occupation_standard, rapids_code: "1234")
      os2 = create(:occupation_standard, rapids_code: "1234CB")
      create(:occupation_standard, title: "HR", rapids_code: "123")

      params = {q: "1234"}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
    end

    it "allows searching occupation standards by onet code" do
      os1 = create(:occupation_standard, onet_code: "12.3456")
      os2 = create(:occupation_standard, onet_code: "12.34567")
      create(:occupation_standard, title: "HR", onet_code: "12.3")

      params = {q: "12.3456"}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
    end

    it "allows filtering occupation standards by state" do
      ca = create(:state)
      wa = create(:state)
      ra_ca = create(:registration_agency, state: ca)
      ra_wa = create(:registration_agency, state: wa)
      os1 = create(:occupation_standard, registration_agency: ra_ca)
      os2 = create(:occupation_standard, registration_agency: ra_ca)
      create(:occupation_standard, registration_agency: ra_wa)

      params = {state_id: ca.id}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
    end

    it "allows filtering occupation standards by state abbreviation" do
      ca = create(:state, abbreviation: "CA")
      wa = create(:state, abbreviation: "WA")
      ra_ca = create(:registration_agency, state: ca)
      ra_wa = create(:registration_agency, state: wa)
      os1 = create(:occupation_standard, registration_agency: ra_ca)
      os2 = create(:occupation_standard, registration_agency: ra_ca)
      create(:occupation_standard, registration_agency: ra_wa)

      params = {state: ca.abbreviation}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
    end

    it "allows filtering occupation standards by multiple national_standard_types" do
      os1 = create(:occupation_standard, :program_standard)
      os2 = create(:occupation_standard, :guideline_standard)
      create(:occupation_standard, :occupational_framework)

      params = {
        national_standard_type: {
          program_standard: "1",
          guideline_standard: "1"
        }
      }

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
    end

    it "allows filtering occupation standards by multiple ojt_types" do
      os1 = create(:occupation_standard, :time)
      os2 = create(:occupation_standard, :hybrid)
      create(:occupation_standard, :competency)

      params = {
        ojt_type: {
          time: "1",
          hybrid: "1"
        }
      }

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
    end

    it "allows searching by title and filtering occupation standards by state and national_standard_type and ojt_type" do
      ca = create(:state)
      wa = create(:state)
      ra_ca = create(:registration_agency, state: ca)
      ra_wa = create(:registration_agency, state: wa)

      os1 = create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_wa, title: "Mechanic")
      create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_wa, title: "HR")
      create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_ca, title: "Mechanic")
      create(:occupation_standard, :program_standard, :time, registration_agency: ra_wa, title: "Mechanic")
      create(:occupation_standard, :guideline_standard, :hybrid, registration_agency: ra_wa, title: "Mechanic")

      params = {
        q: "mech",
        state_id: wa.id,
        national_standard_type: {program_standard: "1"},
        ojt_type: {hybrid: "1"}
      }

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id)
    end

    it "allows searching by industry name" do
      industry1 = create(:industry, name: "Healthcare Support Occupations")
      industry2 = create(:industry, name: "Repair Occupations")

      occupation_standard = create(:occupation_standard, industry: industry1)
      create(:occupation_standard, industry: industry2)

      params = {q: "healthcare support"}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to eq [occupation_standard.id]
    end
  end

  context "when elasticsearch for search is enabled", :elasticsearch do
    around(:each) do |example|
      Flipper.enable(:use_elasticsearch_for_search)
      example.run
      Flipper.disable(:use_elasticsearch_for_search)
    end

    it "allows searching occupation standards by title" do
      occupation_standard_for_mechanic = create(:occupation_standard, title: "Mechanic")
      create(:occupation_standard, title: "Pipe Fitter")
      params = {q: "Mechanic"}

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to eq [occupation_standard_for_mechanic.id]
    end

    it "allows searching occupation standards by rapids code" do
      os1 = create(:occupation_standard, rapids_code: "1234")
      os2 = create(:occupation_standard, rapids_code: "1234CB")
      create(:occupation_standard, title: "HR", rapids_code: "123")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      params = {q: "1234"}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)

      params = {q: "34CB"}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os2.id)
    end

    it "allows searching occupation standards by onet code" do
      os1 = create(:occupation_standard, onet_code: "12.3456")
      os2 = create(:occupation_standard, onet_code: "12.34567")
      create(:occupation_standard, title: "HR", onet_code: "12.3")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      params = {q: "12.3456"}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
    end

    it "allows filtering occupation standards by state id" do
      ca = create(:state)
      wa = create(:state)
      ra_ca = create(:registration_agency, state: ca)
      ra_wa = create(:registration_agency, state: wa)
      os1 = create(:occupation_standard, registration_agency: ra_ca)
      os2 = create(:occupation_standard, registration_agency: ra_ca)
      create(:occupation_standard, registration_agency: ra_wa)

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      params = {state_id: ca.id}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
    end

    it "allows filtering occupation standards by state abbreviation" do
      ca = create(:state, abbreviation: "CA")
      wa = create(:state, abbreviation: "WA")
      ra_ca = create(:registration_agency, state: ca)
      ra_wa = create(:registration_agency, state: wa)
      os1 = create(:occupation_standard, registration_agency: ra_ca)
      os2 = create(:occupation_standard, registration_agency: ra_ca)
      create(:occupation_standard, registration_agency: ra_wa)

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      params = {state: ca.abbreviation}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
    end

    it "allows filtering occupation standards by multiple national_standard_types" do
      os1 = create(:occupation_standard, :program_standard)
      os2 = create(:occupation_standard, :guideline_standard)
      create(:occupation_standard, :occupational_framework)

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      params = {
        national_standard_type: {
          program_standard: "1",
          guideline_standard: "1"
        }
      }

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
    end

    it "allows filtering occupation standards by multiple ojt_types" do
      os1 = create(:occupation_standard, :time)
      os2 = create(:occupation_standard, :hybrid)
      create(:occupation_standard, :competency)

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      params = {
        ojt_type: {
          time: "1",
          hybrid: "1"
        }
      }

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
    end

    it "allows searching by title and filtering occupation standards by state and national_standard_type and ojt_type" do
      ca = create(:state)
      wa = create(:state)
      ra_ca = create(:registration_agency, state: ca)
      ra_wa = create(:registration_agency, state: wa)

      os1 = create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_wa, title: "Mechanic")
      create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_wa, title: "HR")
      create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_ca, title: "Mechanic")
      create(:occupation_standard, :program_standard, :time, registration_agency: ra_wa, title: "Mechanic")
      create(:occupation_standard, :guideline_standard, :hybrid, registration_agency: ra_wa, title: "Mechanic")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      params = {
        q: "mech",
        state_id: wa.id,
        national_standard_type: {program_standard: "1"},
        ojt_type: {hybrid: "1"}
      }

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id)
    end

    it "allows searching by industry name" do
      industry1 = create(:industry, name: "Healthcare Support Occupations")
      industry2 = create(:industry, name: "Repair Occupations")

      occupation_standard = create(:occupation_standard, industry: industry1)
      create(:occupation_standard, industry: industry2)

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      params = {q: "HEALTHCARE Support"}

      occupation_standard_search = OccupationStandardQuery.run(
        OccupationStandard.all, params
      )

      expect(occupation_standard_search.pluck(:id)).to eq [occupation_standard.id]
    end
  end
end
