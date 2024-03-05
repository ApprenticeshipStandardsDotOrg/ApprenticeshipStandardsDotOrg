require "rails_helper"

RSpec.describe ImportViaChatgpt::WorkProcesses, type: :model do
  describe ".extract" do
    it "populates db with a work process" do
      occupation_standard = create(:occupation_standard)
      description = "Length of Training"
      hour_bounds = [2, 2]

      expect {
        described_class.extract(occupation_standard:, description:, hour_bounds:)
      }.to change(WorkProcess, :count).by(1)
    end
  end
end
