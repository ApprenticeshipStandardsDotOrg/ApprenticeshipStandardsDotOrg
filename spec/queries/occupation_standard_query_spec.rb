require "rails_helper"

RSpec.describe OccupationStandardQuery do
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
    ra_ca = create(:registration_agency, for_state_abbreviation: "CA")
    ra_wa = create(:registration_agency, for_state_abbreviation: "WA")

    os1 = create(:occupation_standard, registration_agency: ra_ca)
    os2 = create(:occupation_standard, registration_agency: ra_ca)
    create(:occupation_standard, registration_agency: ra_wa)

    params = {state_id: ra_ca.state_id}

    occupation_standard_search = OccupationStandardQuery.run(
      OccupationStandard.all, params
    )

    expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
  end

  it "allows filtering occupation standards by state abbreviation" do
    ra_ca = create(:registration_agency, for_state_abbreviation: "CA")
    ra_wa = create(:registration_agency, for_state_abbreviation: "WA")

    os1 = create(:occupation_standard, registration_agency: ra_ca)
    os2 = create(:occupation_standard, registration_agency: ra_ca)
    create(:occupation_standard, registration_agency: ra_wa)

    params = {state: ra_ca.state.abbreviation}

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
    ra_ca = create(:registration_agency, for_state_abbreviation: "CA")
    ra_wa = create(:registration_agency, for_state_abbreviation: "WA")

    os1 = create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_wa, title: "Mechanic")
    create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_wa, title: "HR")
    create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_ca, title: "Mechanic")
    create(:occupation_standard, :program_standard, :time, registration_agency: ra_wa, title: "Mechanic")
    create(:occupation_standard, :guideline_standard, :hybrid, registration_agency: ra_wa, title: "Mechanic")

    params = {
      q: "mech",
      state_id: ra_wa.state_id,
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
