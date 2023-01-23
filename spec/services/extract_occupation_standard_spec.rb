require "rails_helper"

RSpec.describe ExtractOccupationStandard, type: :service do
  describe "#call" do
    it "creates occupation standards records" do
      ca = create(:state, abbreviation: "CA")
      ca_oa = create(:registration_agency, state: ca, agency_type: :oa)
      _ca_saa = create(:registration_agency, state: ca, agency_type: :saa)

      onet_code = create(:onet_code, code: "13-1071.01")
      occupation1 = create(:occupation, rapids_code: "1057")
      _occupation2 = create(:occupation, onet_code: onet_code)

      service = described_class.new()

      expect{
        service.call
      }.to change(OccupationStandard, :count).by(1)
        .and change(Organization, :count).by(1)

      os = OccupationStandard.last
      expect(os.occupation).to eq occupation1
      expect(os.registration_agency).to eq ca_oa
      expect(os.title).to eq "HUMAN RESOURCE SPECIALIST"
      expect(os.existing_title).to eq "Career Development Technician"
      expect(os.term_months).to eq 30
      expect(os).to be competency_based
      expect(os.probationary_period_months).to eq 3
      expect(os.sponsor_name).to be_nil
      expect(os.onet_code).to eq "13-1071.01"
      expect(os.rapids_code).to eq "1057"
      expect(os.apprenticeship_to_journeyworker_ratio).to eq "5:1"
      expect(os.organization).to eq Organization.last
      expect(os.ojt_hours_min).to be_nil
      expect(os.ojt_hours_max).to be_nil
      expect(os.rsi_hours_min).to be_nil
      expect(os.rsi_hours_max).to be_nil
    end
  end
end
