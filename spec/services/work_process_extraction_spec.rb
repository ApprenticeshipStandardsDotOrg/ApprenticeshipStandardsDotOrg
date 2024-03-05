# require "rails_helper"

# RSpec.describe WorkProcessExtraction do
#   describe ".extract" do
#     context "with competency data" do
#       it "populates db with both work process and competencies" do
#         occupation_standard = create(:occupation_standard)
#         competency_data = {skill_title: "Title", sort_order: "Asc"}
#         description = "Length of Training"
#         hour_bounds = [2, 2]

#         expect {
#           described_class.extract(occupation_standard:, competency_data:, description:, hour_bounds:)
#         }.to change(WorkProcess, :count).by(1).and change(Competency, :count).by(1)
#       end
#     end

#     context "without competency data" do
#       it "populates db with work process, but no competenies" do
#         occupation_standard = create(:occupation_standard)
#         description = "Length of Training"
#         hour_bounds = [2, 2]

#         expect {
#           described_class.extract(occupation_standard:, description:, hour_bounds:)
#         }.to change(WorkProcess, :count).by(1).and change(Competency, :count).by(0)
#       end
#     end
#   end
# end
