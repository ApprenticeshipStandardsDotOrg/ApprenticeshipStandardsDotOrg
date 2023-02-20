require "rails_helper"

RSpec.describe "occupation_standards/show.html.erb", type: :view do
  it "displays title and description" do
    occupation_standard = create(:occupation_standard, title: "Mechanic")
    assign(:occupation_standard, occupation_standard)

    render

    expect(rendered).to have_selector("h1", text: "Occupation Standard for Mechanic")

    expect(rendered).to have_selector("dt", text: "Occupation:")
    expect(rendered).to have_selector("dt", text: "URL:")
    expect(rendered).to have_selector("dt", text: "Registration Agency:")
    expect(rendered).to have_selector("dt", text: "RAPIDS code:")
    expect(rendered).to have_selector("dt", text: "ONET code:")
    expect(rendered).to have_selector("dt", text: "Created at:")
    expect(rendered).to have_selector("dt", text: "Updated at:")

    expect(rendered).to have_selector("dd", text: occupation_standard.occupation.name)
    expect(rendered).to have_selector("dd", text: occupation_standard.url)
    expect(rendered).to have_selector("dd", text: occupation_standard.registration_agency)
    expect(rendered).to have_selector("dd", text: occupation_standard.rapids_code)
    expect(rendered).to have_selector("dd", text: occupation_standard.onet_code)
    expect(rendered).to have_selector("dd", text: occupation_standard.created_at)
    expect(rendered).to have_selector("dd", text: occupation_standard.updated_at)

    expect(rendered).to have_selector("h3", text: "Related Instructions")

    expect(rendered).to have_columnheader("Title")
    expect(rendered).to have_columnheader("Sort Order")
    expect(rendered).to have_columnheader("Hours")
    expect(rendered).to have_columnheader("Elective")

    expect(rendered).to have_selector("h3", text: "Work Processes")

    expect(rendered).to have_columnheader("Title")
    expect(rendered).to have_columnheader("Sort Order")
    expect(rendered).to have_columnheader("Description")
    expect(rendered).to have_columnheader("Default Hours")
    expect(rendered).to have_columnheader("Minimum Hours")
    expect(rendered).to have_columnheader("Maximum Hours")

    expect(rendered).to have_link("Edit", href: edit_occupation_standard_path(occupation_standard))
  end

  it "allows for occupation standard not linked to an occupation" do
    occupation_standard = create(:occupation_standard, occupation: nil)
    assign(:occupation_standard, occupation_standard)

    render

    expect(rendered).to have_selector("h1", text: "Occupation Standard for #{occupation_standard.title}")
    expect(rendered).to have_selector("dt", text: "Occupation:")
  end
end
