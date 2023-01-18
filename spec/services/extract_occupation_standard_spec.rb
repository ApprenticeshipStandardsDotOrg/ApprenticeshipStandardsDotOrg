require "rails_helper"

RSpec.describe ExtractOccupationStandard, type: :service do
  describe "#call" do
    it "creates occupation standards records" do
      ca = create(:state, abbreviation: "CA")
      ca_oa = create(:registration_agency, state: ca, agency_type: :oa)
      _ca_saa = create(:registration_agency, state: ca, agency_type: :saa)

      az = create(:state, abbreviation: "AZ")
      az_saa = create(:registration_agency, state: az, agency_type: :saa)

      ri = create(:state, abbreviation: "RI")
      ri_saa = create(:registration_agency, state: ri, agency_type: :saa)

      onet_code1 = create(:onet_code, code: "49-2092.00")
      occupation1 = create(:occupation, rapids_code: 1034, onet_code: onet_code1, name: "UNDERCAR SPECIALIST (Alternate Title: Automotive Tech Specialist )")

      onet_code2 = create(:onet_code, code: "13-1071.00")
      occupation2 = create(:occupation, onet_code: onet_code2, name: "CAREER DEVELOPMENT TECHNICIAN")

      service = described_class.new()

      expect{
        service.call
      }.to change(OccupationStandard, :count).by(3)

      os1 = OccupationStandard.first
      expect(os1.occupation).to eq occupation1
      expect(os1.registration_agency).to eq ca_oa
      expect(os1.sponsor_name).to eq "Automotive Specialists R Us"
      expect(os1.title).to eq "AN AUTOMOTIVE TECHNICIAN SPECIALIST"
      expect(os1.term_months).to eq 30
      expect(os1.ojt_hours.first).to eq 1200
      expect(os1.ojt_hours.last).to eq 1400
      expect(os1.rsi_hours.first).to eq 800
      expect(os1.rsi_hours.last).to eq 900
      expect(os1.apprenticeship_to_journeyworker_ratio).to eq 1
      expect(os1).to be competency_based
      expect(os1.probationary_period_months).to eq 6

      os2 = OccupationStandard.second
      expect(os2.occupation).to eq occupation2
      expect(os2.registration_agency).to eq az_saa
      expect(os2.sponsor_name).to eq "Human Resources R Us"
      expect(os2.title).to eq "A HUMAN RESOURCE SPECIALIST"
      expect(os2.term_months).to eq 24
      expect(os2.ojt_hours.first).to eq 20
      expect(os2.ojt_hours.last).to eq 30
      expect(os2.rsi_hours.first).to eq 144
      expect(os2.rsi_hours.last).to eq 200
      expect(os2.apprenticeship_to_journeyworker_ratio).to eq 0.2
      expect(os2).to be time_based
      expect(os2.probationary_period_months).to eq 3

      os3 = OccupationStandard.third
      expect(os3.occupation).to be_nil
      expect(os3.registration_agency).to eq ri_saa
      expect(os3.sponsor_name).to eq "Cameras R Us"
      expect(os3.title).to eq "To be a Camera Operator"
      expect(os3.onet_code).to eq "12-3456.00"
      expect(os3.rapids_code).to eq "2345"
      expect(os3.term_months).to eq 15
      expect(os3.ojt_hours.first).to eq 100
      expect(os3.ojt_hours.last).to eq 200
      expect(os3.rsi_hours.first).to eq 300
      expect(os3.rsi_hours.last).to eq 400
      expect(os3.apprenticeship_to_journeyworker_ratio).to eq 0.1
      expect(os3).to be hybrid_based
      expect(os3.probationary_period_months).to eq 2
    end
  end
end
