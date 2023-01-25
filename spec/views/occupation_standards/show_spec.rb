require "rails_helper"

RSpec.describe "occupation_standards/show.html.erb", type: :view do
  it "displays name and description", :admin do
    occupation_standard = build(:occupation_standard)
    assign(:occupation_standard, occupation_standard)

    render

    expect(rendered).to have_selector("h2", text: "Occupation Standard for #{occupation_standard.occupation.name}")

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
  end
end
