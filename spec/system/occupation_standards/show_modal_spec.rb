require "rails_helper"

RSpec.describe "OccupationStandardShowModal" do
  context "for first time visit" do
    it "does not show modal" do
      occupation_standard = create(:occupation_standard, :with_data_import)

      visit occupation_standard_path(occupation_standard)

      expect(page).to_not have_modal("Apprenticeship Standard Survey")
    end
  end

  context "for second visit" do
    it "updates cookie" do
      occupation_standard = create(:occupation_standard, :with_data_import)

      visit occupation_standard_path(occupation_standard)

      visit occupation_standard_path(occupation_standard)

      expect(page).to have_modal("Apprenticeship Standard Survey")
    end
  end
end
