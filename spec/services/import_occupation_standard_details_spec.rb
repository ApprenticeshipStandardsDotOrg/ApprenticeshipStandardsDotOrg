require "rails_helper"

RSpec.describe ImportOccupationStandardDetails do
  describe "#call" do
    it "returns an occupation standards record" do
      ca = create(:state, abbreviation: "CA")
      create(:registration_agency, state: ca, agency_type: :oa)

      data_import = create(:data_import, :unprocessed)

      os = described_class.new(data_import).call
      expect(os).to be_a(OccupationStandard)
    end

    context "when data_import has no occupation_standard associated" do
      it "creates an occupation standards record for time-based" do
        ca = create(:state, abbreviation: "CA")
        ca_oa = create(:registration_agency, state: ca, agency_type: :oa)
        _ca_saa = create(:registration_agency, state: ca, agency_type: :saa)

        onet = create(:onet, code: "13-1071.01")
        occupation1 = create(:occupation, rapids_code: "0157")
        _occupation2 = create(:occupation, onet: onet)

        data_import = create(:data_import, :unprocessed)

        expect {
          described_class.new(data_import).call
        }.to change(OccupationStandard, :count).by(1)

        os = OccupationStandard.last
        expect(os.data_import).to eq data_import
        expect(os.occupation).to eq occupation1
        expect(os.registration_agency).to eq ca_oa
        expect(os.title).to eq "HUMAN RESOURCE SPECIALIST"
        expect(os.existing_title).to eq "Career Development Technician"
        expect(os.term_months).to eq 12
        expect(os).to be_competency_based
        expect(os.probationary_period_months).to eq 3
        expect(os.onet_code).to eq "13-1071.01"
        expect(os.rapids_code).to eq "0157"
        expect(os.apprenticeship_to_journeyworker_ratio).to eq "5:1"
        expect(os.organization_title).to eq "Hardy Corporation"
        expect(os.ojt_hours_min).to be_nil
        expect(os.ojt_hours_max).to be_nil
        expect(os.rsi_hours_min).to be_nil
        expect(os.rsi_hours_max).to be_nil
      end

      it "creates an occupation standards record for competency-based" do
        ca = create(:state, abbreviation: "CA")
        ca_oa = create(:registration_agency, state: ca, agency_type: :oa)

        create(:onet, code: "13-1071.01")
        occupation1 = create(:occupation, rapids_code: "0157")

        data_import = create(:data_import, :hybrid, :unprocessed)

        expect {
          described_class.new(data_import).call
        }.to change(OccupationStandard, :count).by(1)

        os = OccupationStandard.last
        expect(os.data_import).to eq data_import
        expect(os.occupation).to eq occupation1
        expect(os.registration_agency).to eq ca_oa
        expect(os.title).to eq "HUMAN RESOURCE SPECIALIST"
        expect(os.existing_title).to eq "Career Development Technician"
        expect(os.term_months).to eq 12
        expect(os).to be_competency_based
        expect(os.probationary_period_months).to eq 3
        expect(os.onet_code).to eq "13-1071.01"
        expect(os.rapids_code).to eq "0157"
        expect(os.apprenticeship_to_journeyworker_ratio).to eq "5:1"
        expect(os.organization_title).to eq "Hardy Corporation"
        expect(os.ojt_hours_min).to be_nil
        expect(os.ojt_hours_max).to be_nil
        expect(os.rsi_hours_min).to be_nil
        expect(os.rsi_hours_max).to be_nil
      end
    end

    context "when data_import already has an occupation_standard associated" do
      it "updates the occupation standards record" do
        ca = create(:state, abbreviation: "CA")
        ca_oa = create(:registration_agency, state: ca, agency_type: :oa)

        create(:onet, code: "13-1071.01")
        occupation = create(:occupation, rapids_code: "0157")

        data_import = create(:data_import)
        os = data_import.occupation_standard

        expect {
          described_class.new(data_import).call
        }.to_not change(OccupationStandard, :count)

        os.reload
        expect(os.data_import).to eq data_import
        expect(os.occupation).to eq occupation
        expect(os.registration_agency).to eq ca_oa
        expect(os.title).to eq "HUMAN RESOURCE SPECIALIST"
        expect(os.existing_title).to eq "Career Development Technician"
        expect(os.term_months).to eq 12
        expect(os).to be_competency_based
        expect(os.probationary_period_months).to eq 3
        expect(os.onet_code).to eq "13-1071.01"
        expect(os.rapids_code).to eq "0157"
        expect(os.apprenticeship_to_journeyworker_ratio).to eq "5:1"
        expect(os.organization_title).to eq "Hardy Corporation"
        expect(os.ojt_hours_min).to be_nil
        expect(os.ojt_hours_max).to be_nil
        expect(os.rsi_hours_min).to be_nil
        expect(os.rsi_hours_max).to be_nil
      end
    end
  end
end
