require "rails_helper"

RSpec.describe "occupation_standards/index.html.erb", type: :view do
  it "displays name and description", :admin do
    occupation_standards = create_list(:occupation_standard, 1)
    occupation_standard = occupation_standards.first
    assign(:occupation_standards, occupation_standards)

    render

    expect(rendered).to have_selector("h2", text: "Occupation Standards")
    expect(rendered).to have_columnheader("ID")
    expect(rendered).to have_columnheader("Occupation")
    expect(rendered).to have_columnheader("Registration Agency")
    expect(rendered).to have_columnheader("RAPIDS code")
    expect(rendered).to have_columnheader("ONET code")

    expect(rendered).to have_link(occupation_standard.id, href: occupation_standard_path(occupation_standard))
    expect(rendered).to have_gridcell(occupation_standard.rapids_code)
    expect(rendered).to have_gridcell(occupation_standard.onet_code)
  end
end
