require "rails_helper"

RSpec.describe OccupationStandardElasticsearchQuery, :elasticsearch do
  it "retrieves all records if params empty, giving priority to national occupational framework standards" do
    os1 = create(:occupation_standard)
    os2 = create(:occupation_standard, :occupational_framework)
    os3 = create(:occupation_standard)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    response = described_class.new(search_params: {}).call

    expect(response.records.pluck(:id)).to eq [os2.id, os3.id, os1.id]
  end

  it "limits size" do
    default_items = Pagy::DEFAULT[:items]
    Pagy::DEFAULT[:items] = 2
    create(:occupation_standard)
    occupation_standards = create_list(:occupation_standard, 2)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    response = described_class.new(search_params: {}).call

    expect(response.records).to match_array occupation_standards
    Pagy::DEFAULT[:items] = default_items
  end

  it "takes offset param" do
    default_items = Pagy::DEFAULT[:items]
    Pagy::DEFAULT[:items] = 2
    occupation_standard = create(:occupation_standard)
    create_list(:occupation_standard, 2)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    response = described_class.new(search_params: {}, offset: 2).call

    expect(response.records).to match_array [occupation_standard]
    Pagy::DEFAULT[:items] = default_items
  end

  it "allows searching occupation standards by title" do
    os1 = create(:occupation_standard, title: "Amazing Drone Operator Extraordinaire")
    os2 = create(:occupation_standard, title: "Drone Operator")
    os3 = create(:occupation_standard, title: "Operator of Drones")
    os4 = create(:occupation_standard, title: "Drone Extraordinaire")
    create(:occupation_standard, title: "Mechanic")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "amazing drone Operator Extra"}
    response = described_class.new(search_params: params).call

    record_ids = response.records.pluck(:id)
    expect(record_ids).to contain_exactly(os1.id, os2.id, os3.id, os4.id)
    expect(record_ids.first).to eq os1.id

    params = {q: "Drones"}
    response = described_class.new(search_params: params).call

    record_ids = response.records.pluck(:id)
    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id, os3.id, os4.id)

    params = {q: "Operate"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id, os3.id)

    params = {q: "drone extraordinaire"}
    response = described_class.new(search_params: params).call

    record_ids = response.records.pluck(:id)
    expect(record_ids.first).to eq os4.id
    expect(record_ids.second).to eq os1.id
    expect(record_ids).to contain_exactly(os1.id, os2.id, os3.id, os4.id)

    params = {q: "amazing OPERATOR"}
    response = described_class.new(search_params: params).call

    record_ids = response.records.pluck(:id)
    expect(record_ids.first).to eq os1.id
    expect(record_ids).to contain_exactly(os1.id, os2.id, os3.id)

    params = {q: "drone operator"}
    response = described_class.new(search_params: params).call

    record_ids = response.records.pluck(:id)
    expect(record_ids).to eq [os2.id, os1.id, os3.id, os4.id]

    params = {q: "operator drones"}
    response = described_class.new(search_params: params).call

    record_ids = response.records.pluck(:id)
    expect(record_ids.first).to eq os3.id
    expect(record_ids).to contain_exactly(os1.id, os2.id, os3.id, os4.id)
  end

  it "allows searching occupation standards by rapids code" do
    os1 = create(:occupation_standard, rapids_code: "1234")
    os2 = create(:occupation_standard, rapids_code: "1234CB")
    create(:occupation_standard, title: "HR", rapids_code: "123")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "1234"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id)

    params = {q: "34CB"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os2.id)
  end

  it "allows searching occupation standards by onet code" do
    os1 = create(:occupation_standard, onet_code: "12.3456")
    os2 = create(:occupation_standard, onet_code: "12.34567")
    create(:occupation_standard, title: "HR", onet_code: "12.3")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "12.3456"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id)
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
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id)
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
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id)
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
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id)
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
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id)
  end

  it "allows searching by title and filtering occupation standards by state and national_standard_type and ojt_type" do
    ca = create(:state)
    wa = create(:state)
    ra_ca = create(:registration_agency, state: ca)
    ra_wa = create(:registration_agency, state: wa)

    os1 = create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_wa, title: "Pipe Fitter")
    create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_wa, title: "HR")
    create(:occupation_standard, :program_standard, :hybrid, registration_agency: ra_ca, title: "Pipe Fitter")
    create(:occupation_standard, :program_standard, :time, registration_agency: ra_wa, title: "Pipe Fitter")
    create(:occupation_standard, :guideline_standard, :hybrid, registration_agency: ra_wa, title: "Pipe Fitter")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {
      q: "pipe",
      state_id: wa.id,
      national_standard_type: {program_standard: "1"},
      ojt_type: {hybrid: "1"}
    }
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id)
  end

  it "allows searching by industry name" do
    industry1 = create(:industry, name: "Healthcare Support Occupations")
    industry2 = create(:industry, name: "Repair Occupations")

    os1 = create(:occupation_standard, industry: industry1)
    os2 = create(:occupation_standard, title: "Healthcare Specialist")
    create(:occupation_standard, industry: industry2)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "HEALTHCARE Extraordinaire"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to eq [os2.id, os1.id]
  end

  it "boosts national occupation framework standards" do
    os1 = create(:occupation_standard, :occupational_framework, title: "Mechanic")
    os2 = create(:occupation_standard, :program_standard, title: "Mechanic")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "Mechanic"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to eq [os1.id, os2.id]
  end

  it "returns results that match on related_job_titles" do
    create(:onet, code: "1234.56", related_job_titles: ["Some other tax job", "Auditor"])
    os1 = create(:occupation_standard, title: "Specialist of Taxes")
    _os2 = create(:occupation_standard, title: "Pipe Fitter")
    os3 = create(:occupation_standard, title: "Accounting specialist", onet_code: "1234.56")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "taxing"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to eq [os1.id, os3.id]
  end
end
