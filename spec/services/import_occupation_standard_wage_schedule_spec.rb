require "rails_helper"

RSpec.describe ImportOccupationStandardWageSchedule do
  describe "#call" do
    it "returns wage schedule record" do
      occupation_standard = create(:occupation_standard)
      data_import = create(:data_import)

      wage_schedules = described_class.new(
        occupation_standard: occupation_standard,
        data_import: data_import
      ).call

      ws1 = wage_schedules.first
      expect(ws1.occupation_standard).to eq occupation_standard
      expect(ws1.sort_order).to eq 1
      expect(ws1.title).to eq "Step 1"
      expect(ws1.minimum_hours).to eq 60
      expect(ws1.ojt_percentage).to eq 0.25
      expect(ws1.duration_in_months).to eq 6
      expect(ws1.rsi_hours).to eq 60

      ws2 = wage_schedules.second
      expect(ws2.occupation_standard).to eq occupation_standard
      expect(ws2.sort_order).to eq 2
      expect(ws2.title).to eq "Step 2"
      expect(ws2.minimum_hours).to eq 60
      expect(ws2.ojt_percentage).to eq 0.25
      expect(ws2.duration_in_months).to eq 6
      expect(ws2.rsi_hours).to eq 75

      ws3 = wage_schedules.third
      expect(ws3.occupation_standard).to eq occupation_standard
      expect(ws3.sort_order).to eq 1
      expect(ws3.title).to eq "Step 1"
      expect(ws3.minimum_hours).to eq 40
      expect(ws3.ojt_percentage).to eq 0.10
      expect(ws3.duration_in_months).to eq 4
      expect(ws3.rsi_hours).to eq 75
    end
  end
end
