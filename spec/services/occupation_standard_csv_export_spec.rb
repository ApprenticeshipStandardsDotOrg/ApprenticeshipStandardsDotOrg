require "rails_helper"

RSpec.describe OccupationStandardCsvExport do
  describe "#to_csv" do
    it "exports all standards ordered by SOC code with process and competency counts" do
      state = create(:state, name: "Washington", abbreviation: "WA")
      registration_agency = create(:registration_agency, state: state)
      organization = create(:organization, title: "Example Sponsor")
      later_standard = create(
        :occupation_standard,
        onet_code: "47-2111.00",
        organization: organization,
        registration_agency: registration_agency,
        source: :ai_conversion,
        title: "Electrician"
      )
      first_work_process = create(:work_process, occupation_standard: later_standard)
      create_list(:competency, 2, work_process: first_work_process)
      create(:work_process, occupation_standard: later_standard)
      create(
        :occupation_standard,
        onet_code: "13-2011.01",
        organization: nil,
        source: :manual_upload,
        title: "Accountant"
      )

      report = CSV.parse(described_class.new.to_csv, headers: true)

      expect(report.headers).to eq described_class::HEADERS
      expect(report.map { |row| row["name"] }).to eq ["Accountant", "Electrician"]
      expect(report.first["soc_code"]).to eq "13-2011"
      expect(report.first["org_name"]).to be_nil
      expect(report.first["ai_converted"]).to eq "0"

      row = report[-1]
      expect(row["soc_code"]).to eq "47-2111"
      expect(row["org_name"]).to eq "Example Sponsor"
      expect(row["state_name"]).to eq "Washington"
      expect(row["source"]).to eq "ai_conversion"
      expect(row["occupation_standard_url"]).to eq(
        "https://apprenticeshipstandards.org/occupation_standards/#{later_standard.id}"
      )
      expect(row["num_processes"]).to eq "2"
      expect(row["num_competencies"]).to eq "2"
      expect(row["ai_converted"]).to eq "1"
    end

    it "places standards without an SOC code last" do
      create(:occupation_standard, onet_code: nil, title: "Unknown SOC")
      create(:occupation_standard, onet_code: "51-1011.00", title: "Known SOC")

      report = CSV.parse(described_class.new.to_csv, headers: true)

      expect(report.map { |row| row["name"] }).to eq ["Known SOC", "Unknown SOC"]
      expect(report[-1]["soc_code"]).to be_nil
    end

    it "leaves state blank for legacy standards without a registration agency" do
      occupation_standard = create(:occupation_standard, onet_code: "11-1011.00")
      occupation_standard.update_column(:registration_agency_id, nil)

      report = CSV.parse(described_class.new.to_csv, headers: true)

      expect(report.first["state_name"]).to be_nil
    end
  end
end
