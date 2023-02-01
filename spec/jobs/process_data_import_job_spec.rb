require "rails_helper"

RSpec.describe ProcessDataImportJob, type: :job do
  describe "#perform" do
    it "calls ImportOccupationStandardDetails service" do
      data_import = build_stubbed(:data_import)
      service = instance_double("ImportOccupationStandardDetails")

      expect(ImportOccupationStandardDetails).to receive(:new).with(data_import).and_return(service)
      expect(service).to receive(:call).and_return(build(:occupation))

      described_class.new.perform(data_import)
    end

    it "creates an occupation standard when new record" do
      ca = create(:state, abbreviation: "CA")
      ca_oa = create(:registration_agency, state: ca, agency_type: :oa)
      _ca_saa = create(:registration_agency, state: ca, agency_type: :saa)

      onet_code = create(:onet_code, code: "13-1071.01")
      occupation1 = create(:occupation, rapids_code: "1057")
      _occupation2 = create(:occupation, onet_code: onet_code)

      data_import = create(:data_import)

      expect {
        described_class.new.perform(data_import)
      }.to change(OccupationStandard, :count).by(1)
        .and change(Organization, :count).by(0)

      occupation_standard = OccupationStandard.last
      expect(occupation_standard.data_import).to eq data_import
      expect(occupation_standard.occupation).to eq occupation1
      expect(occupation_standard.registration_agency).to eq ca_oa
      expect(occupation_standard.title).to eq "HUMAN RESOURCE SPECIALIST"
      expect(occupation_standard.existing_title).to eq "Career Development Technician"
      expect(occupation_standard.term_months).to eq 12
      expect(occupation_standard).to be_competency_based
      expect(occupation_standard.probationary_period_months).to eq 3
      expect(occupation_standard.onet_code).to eq "13-1071.01"
      expect(occupation_standard.rapids_code).to eq "1057"
      expect(occupation_standard.apprenticeship_to_journeyworker_ratio).to eq "5:1"
      expect(occupation_standard.organization).to be_nil
      expect(occupation_standard.ojt_hours_min).to be_nil
      expect(occupation_standard.ojt_hours_max).to be_nil
      expect(occupation_standard.rsi_hours_min).to be_nil
      expect(occupation_standard.rsi_hours_max).to be_nil
    end

    it "updates an occupation standard when it exists" do
      ca = create(:state, abbreviation: "CA")
      ca_oa = create(:registration_agency, state: ca, agency_type: :oa)

      occupation = create(:occupation, rapids_code: "1057")

      data_import = create(:data_import)
      occupation_standard = create(:occupation_standard, data_import: data_import)

      expect {
        described_class.new.perform(data_import)
      }.to_not change(OccupationStandard, :count)

      occupation_standard.reload
      expect(occupation_standard.data_import).to eq data_import
      expect(occupation_standard.occupation).to eq occupation
      expect(occupation_standard.registration_agency).to eq ca_oa
      expect(occupation_standard.title).to eq "HUMAN RESOURCE SPECIALIST"
      expect(occupation_standard.existing_title).to eq "Career Development Technician"
      expect(occupation_standard.term_months).to eq 12
      expect(occupation_standard).to be_competency_based
      expect(occupation_standard.probationary_period_months).to eq 3
      expect(occupation_standard.onet_code).to eq "13-1071.01"
      expect(occupation_standard.rapids_code).to eq "1057"
      expect(occupation_standard.apprenticeship_to_journeyworker_ratio).to eq "5:1"
      expect(occupation_standard.organization).to be_nil
      expect(occupation_standard.ojt_hours_min).to be_nil
      expect(occupation_standard.ojt_hours_max).to be_nil
      expect(occupation_standard.rsi_hours_min).to be_nil
      expect(occupation_standard.rsi_hours_max).to be_nil
    end
  end
end
