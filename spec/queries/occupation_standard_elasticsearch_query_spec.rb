require "rails_helper"

RSpec.describe OccupationStandardElasticsearchQuery, :elasticsearch do
  it "retrieves all records with work_processes if params empty, giving priority to national occupational framework standards" do
    os1 = create(:occupation_standard, :with_work_processes)
    os2 = create(:occupation_standard, :with_work_processes, :occupational_framework)
    os3 = create(:occupation_standard, :with_work_processes)
    create(:occupation_standard)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    response = described_class.new(search_params: {}).call

    expect(response.records.pluck(:id)).to eq [os2.id, os3.id, os1.id]
  end

  it "limits size" do
    default_items = Pagy::DEFAULT[:limit]
    Pagy::DEFAULT[:limit] = 2
    create(:occupation_standard, :with_work_processes)
    occupation_standards = create_list(:occupation_standard, 2, :with_work_processes)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    response = described_class.new(search_params: {}).call

    expect(response.records).to match_array occupation_standards
    Pagy::DEFAULT[:limit] = default_items
  end

  it "takes offset param" do
    default_items = Pagy::DEFAULT[:limit]
    Pagy::DEFAULT[:limit] = 2
    occupation_standard = create(:occupation_standard, :with_work_processes)
    create_list(:occupation_standard, 2, :with_work_processes)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    response = described_class.new(search_params: {}, offset: 2).call

    expect(response.records).to match_array [occupation_standard]
    Pagy::DEFAULT[:limit] = default_items
  end

  it "allows searching occupation standards by title" do
    os1 = create(:occupation_standard, :with_work_processes, title: "Amazing Drone Operator Extraordinaire")
    os2 = create(:occupation_standard, :with_work_processes, title: "Drone Operator")
    os3 = create(:occupation_standard, :with_work_processes, title: "Operator of Drones")
    os4 = create(:occupation_standard, :with_work_processes, title: "Drone Extraordinaire")
    create(:occupation_standard, :with_work_processes, title: "Mechanic")
    create(:occupation_standard, :with_work_processes, title: "Amortization Calculator")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "amazing drone Operator Extra"}
    response = described_class.new(search_params: params).call

    record_ids = response.records.pluck(:id)
    expect(record_ids).to contain_exactly(os1.id, os2.id, os3.id, os4.id)
    expect(record_ids.first).to eq os1.id

    params = {q: "Drones"}
    response = described_class.new(search_params: params).call

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
    expect(record_ids.first).to eq os2.id
    expect(record_ids.last).to eq os4.id
    expect(record_ids).to contain_exactly(os2.id, os1.id, os3.id, os4.id)

    params = {q: "operator drones"}
    response = described_class.new(search_params: params).call

    record_ids = response.records.pluck(:id)
    expect(record_ids.first).to eq os3.id
    expect(record_ids).to contain_exactly(os1.id, os2.id, os3.id, os4.id)

    params = {q: "amaz"}
    response = described_class.new(search_params: params).call

    record_ids = response.records.pluck(:id)
    expect(record_ids).to contain_exactly(os1.id)
  end

  it "allows searching occupation standards by rapids code" do
    os1 = create(:occupation_standard, :with_work_processes, rapids_code: "1234")
    os2 = create(:occupation_standard, :with_work_processes, rapids_code: "1234cB")
    create(:occupation_standard, :with_work_processes, title: "HR", rapids_code: "123")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "1234"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id)

    params = {q: "1234Cb"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os2.id)
  end

  it "allows searching occupation standards by onet code" do
    os1 = create(:occupation_standard, :with_work_processes, onet_code: "12-3456")
    create(:occupation_standard, :with_work_processes, onet_code: "12-3457")
    create(:occupation_standard, :with_work_processes, onet_code: "11-2345")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "12-3456"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id)
  end

  it "allows searching occupation standards by other onet code version" do
    onet_2010 = create(:onet, version: "2010", code: "10-3456.00")
    onet_2019 = create(:onet, version: "2019", code: "19-3456.00")
    create(:onet_mapping, onet: onet_2010, next_version_onet: onet_2019)

    os1 = create(:occupation_standard, :with_work_processes, onet_code: "19-3456.00")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "10-3456"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id)
  end

  it "allows filtering occupation standards by onet prefix" do
    os1 = create(:occupation_standard, :with_work_processes, onet_code: "12.3456")
    os2 = create(:occupation_standard, :with_work_processes, onet_code: "12-9876")
    create(:occupation_standard, :with_work_processes, onet_code: "13-3457")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {onet_prefix: "12-1111"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id)
  end

  it "allows filtering occupation standards by state id" do
    ra_ca = create(:registration_agency, for_state_abbreviation: "CA")
    ra_wa = create(:registration_agency, for_state_abbreviation: "WA")
    os1 = create(:occupation_standard, :with_work_processes, registration_agency: ra_ca)
    os2 = create(:occupation_standard, :with_work_processes, registration_agency: ra_ca)
    create(:occupation_standard, :with_work_processes, registration_agency: ra_wa)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {state_id: ra_ca.state.id}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id)
  end

  it "allows filtering occupation standards by state abbreviation" do
    ra_ca = create(:registration_agency, for_state_abbreviation: "CA")
    ra_wa = create(:registration_agency, for_state_abbreviation: "WA")
    os1 = create(:occupation_standard, :with_work_processes, registration_agency: ra_ca)
    os2 = create(:occupation_standard, :with_work_processes, registration_agency: ra_ca)
    create(:occupation_standard, :with_work_processes, registration_agency: ra_wa)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {state: ra_ca.state.abbreviation}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id, os2.id)
  end

  it "allows filtering occupation standards by multiple national_standard_types" do
    os1 = create(:occupation_standard, :with_work_processes, :program_standard)
    os2 = create(:occupation_standard, :with_work_processes, :guideline_standard)
    create(:occupation_standard, :with_work_processes, :occupational_framework)

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
    os1 = create(:occupation_standard, :with_work_processes, :time)
    os2 = create(:occupation_standard, :with_work_processes, :hybrid)
    create(:occupation_standard, :with_work_processes, :competency)

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
    ra_ca = create(:registration_agency, for_state_abbreviation: "CA")
    ra_wa = create(:registration_agency, for_state_abbreviation: "WA")

    os1 = create(:occupation_standard, :with_work_processes, :program_standard, :hybrid, registration_agency: ra_wa, title: "Pipe Fitter")
    create(:occupation_standard, :with_work_processes, :program_standard, :hybrid, registration_agency: ra_wa, title: "HR")
    create(:occupation_standard, :with_work_processes, :program_standard, :hybrid, registration_agency: ra_ca, title: "Pipe Fitter")
    create(:occupation_standard, :with_work_processes, :program_standard, :time, registration_agency: ra_wa, title: "Pipe Fitter")
    create(:occupation_standard, :with_work_processes, :guideline_standard, :hybrid, registration_agency: ra_wa, title: "Pipe Fitter")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {
      q: "pipe",
      state_id: ra_wa.state_id,
      national_standard_type: {program_standard: "1"},
      ojt_type: {hybrid: "1"}
    }
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(os1.id)
  end

  it "allows searching by industry name" do
    industry1 = create(:industry, name: "Healthcare Support Occupations")
    industry2 = create(:industry, name: "Repair Occupations")

    os1 = create(:occupation_standard, :with_work_processes, industry: industry1)
    os2 = create(:occupation_standard, :with_work_processes, title: "Healthcare Specialist")
    create(:occupation_standard, :with_work_processes, industry: industry2)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "HEALTHCARE Extraordinaire"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to eq [os2.id, os1.id]
  end

  it "boosts national occupation framework standards" do
    os1 = create(:occupation_standard, :with_work_processes, :occupational_framework, title: "Mechanic")
    os2 = create(:occupation_standard, :with_work_processes, :program_standard, title: "Mechanic")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "Mechanic"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to eq [os1.id, os2.id]
  end

  it "returns results that match on related_job_titles" do
    create(:onet, code: "1234.56", related_job_titles: ["Some other tax job", "Auditor"])
    os1 = create(:occupation_standard, :with_work_processes, title: "Specialist of Taxes")
    _os2 = create(:occupation_standard, :with_work_processes, title: "Pipe Fitter")
    os3 = create(:occupation_standard, :with_work_processes, title: "Accounting specialist", onet_code: "1234.56")

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "taxing"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to eq [os1.id, os3.id]
  end

  it "returns results that match synonyms" do
    os1 = create(:occupation_standard, :with_work_processes, title: "User experience designer")
    os2 = create(:occupation_standard, :with_work_processes, title: "UX Designer")
    create(:occupation_standard, :with_work_processes, title: "Mechanic")
    synonym = create(:synonym, word: "UX", synonyms: "User experience")
    ElasticsearchWrapper::Synonyms.create_set(
      value: synonym.to_elasticsearch_value,
      rule_id: synonym.id
    )

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "usER expERience"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to match_array [os1.id, os2.id]

    params = {q: "ux design"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to match_array [os2.id, os1.id]
  end

  it "collapses search results across headline" do
    agency = create(:registration_agency)

    os1 = create(:occupation_standard, :time, registration_agency: agency, title: "Pipe Fitter")
    create(:work_process, occupation_standard: os1, sort_order: 2, title: "fox jumps over", maximum_hours: 100)
    create(:work_process, occupation_standard: os1, sort_order: 1, title: "The quick brown", maximum_hours: 200)

    create(:onet, code: "1234.56", related_job_titles: ["pipe"])
    os2 = create(:occupation_standard, :time, onet_code: "1234.56", registration_agency: agency, title: "Pipe Fitter")
    create(:work_process, occupation_standard: os2, sort_order: 2, title: "fox jumps over", maximum_hours: 100)
    create(:work_process, occupation_standard: os2, sort_order: 1, title: "The quick brown", maximum_hours: 200)

    os3 = create(:occupation_standard, :time, registration_agency: agency, title: "Pipe")
    create(:work_process, occupation_standard: os3, sort_order: 2, title: "fox jumps over", maximum_hours: 100)
    create(:work_process, occupation_standard: os3, sort_order: 1, title: "The quick brown", maximum_hours: 200)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {q: "pipe"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to eq [os2.id, os3.id]
    expect(response.results[0].inner_hits.children.first[1].hits[0]._id).to eq os2.id
    expect(response.results[0].inner_hits.children.first[1].hits[1]._id).to eq os1.id
    expect(response.results[1].inner_hits.children.first[1].hits[0]._id).to eq os3.id
    expect(response.response.hits.total.value).to eq 3
    expect(response.response.aggregations.total.value).to eq 2
  end

  it "allows using a field to override default sorting" do
    # Occupations with occupational_framework have a better score by default
    os1 = create(:occupation_standard, :with_work_processes, title: "Technical B", created_at: 1.day.ago)
    os2 = create(:occupation_standard, :with_work_processes, title: "Something else", created_at: 2.day.ago)
    os3 = create(:occupation_standard, :with_work_processes, :occupational_framework, title: "Technical A", created_at: 3.days.ago)

    OccupationStandard.import
    OccupationStandard.__elasticsearch__.refresh_index!

    params = {}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to eq [os3.id, os1.id, os2.id]

    # We are sorting only by created_at dismissing the score
    params = {sort: :created_at}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to eq [os1.id, os2.id, os3.id]
  end
end
