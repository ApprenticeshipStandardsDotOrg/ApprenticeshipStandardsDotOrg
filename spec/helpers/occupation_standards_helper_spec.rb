require "rails_helper"

# Specs in this file have access to a helper object that includes
# the OccupationStandardsHelper. For example:
#
# describe OccupationStandardsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe OccupationStandardsHelper, type: :helper do
  describe "#ojt_type_display" do
    it "returns nil if no ojt_type" do
      occupation_standard = build(:occupation_standard, ojt_type: nil)

      expect(helper.ojt_type_display(occupation_standard)).to be_nil
    end

    it "returns the ojt_type titleized" do
      occupation_standard = build(:occupation_standard, ojt_type: :hybrid)

      expect(helper.ojt_type_display(occupation_standard)).to eq "Hybrid"
    end
  end

  describe "#filters_class" do
    it "returns hidden if no filter params" do
      expect(helper.filters_class).to eq "hidden"
    end

    it "returns nil if filter params" do
      controller.params[:state_id] = "abc123"

      expect(helper.filters_class).to be_nil
    end
  end

  describe "#filters_aria_expanded" do
    it "returns false if no filter params" do
      expect(helper.filters_aria_expanded).to eq "false"
    end

    it "returns true if filter params" do
      controller.params[:state_id] = "abc123"

      expect(helper.filters_aria_expanded).to eq "true"
    end
  end
end
