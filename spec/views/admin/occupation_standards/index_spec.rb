require "rails_helper"

RSpec.describe "admin/occupation_standards/index.html.erb", type: :view do
  context "when occupation" do
    it "displays table with attributes" do
      ca = create(:state, name: "California", abbreviation: "CA")
      agency = create(:registration_agency, state: ca, agency_type: :oa)
      onet_code = create(:onet_code, code: "11-12345.0", name: "Dog Catching Human")
      occupation = create(:occupation, title: "Dog Catcher", rapids_code: "12345", onet_code: onet_code)
      occupation_standard = create(:occupation_standard, occupation: occupation, title: "Dog Catching Technician", registration_agency: agency)

      assign(:occupation_standards, OccupationStandard.all)
      render

      expect(rendered).to have_selector("h1", text: "Occupation Standards")
      expect(rendered).to have_columnheader("Title")
      expect(rendered).to have_columnheader("Occupation")
      expect(rendered).to have_columnheader("Registration Agency")
      expect(rendered).to have_columnheader("ONET code")
      expect(rendered).to have_columnheader("Status")

      expect(rendered).to have_link("Dog Catching Technician", href: admin_occupation_standard_path(occupation_standard))
      expect(rendered).to have_gridcell("Dog Catcher (12345)")
      expect(rendered).to have_gridcell("California (OA)")
      expect(rendered).to have_gridcell("Dog Catching Human (11-12345.0)")
      expect(rendered).to have_gridcell("Importing")

      expect(rendered).to have_link("Edit", href: edit_admin_occupation_standard_path(occupation_standard))
    end
  end

  context "when no occupation" do
    it "displays table with attributes" do
      ca = create(:state, name: "California", abbreviation: "CA")
      agency = create(:registration_agency, state: ca, agency_type: :oa)
      occupation_standard = create(:occupation_standard, onet_code: "11-12345.0", title: "Dog Catching Technician", registration_agency: agency)

      assign(:occupation_standards, OccupationStandard.all)
      render

      expect(rendered).to have_selector("h1", text: "Occupation Standards")
      expect(rendered).to have_columnheader("Title")
      expect(rendered).to have_columnheader("Occupation")
      expect(rendered).to have_columnheader("Registration Agency")
      expect(rendered).to have_columnheader("ONET code")
      expect(rendered).to have_columnheader("Status")

      expect(rendered).to have_link("Dog Catching Technician", href: admin_occupation_standard_path(occupation_standard))
      expect(rendered).to have_gridcell("")
      expect(rendered).to have_gridcell("California (OA)")
      expect(rendered).to have_gridcell("11-12345.0")
      expect(rendered).to have_gridcell("Importing")

      expect(rendered).to have_link("Edit", href: edit_admin_occupation_standard_path(occupation_standard))
    end
  end
end
