require "rails_helper"

RSpec.describe "admin/occupation_standards/show" do
  it "displays title and description", :admin do
    occupation_standard = create(:occupation_standard, title: "Mechanic")
    create(:data_import, occupation_standard: occupation_standard)
    admin = create(:admin)

    login_as admin
    visit admin_occupation_standard_path(occupation_standard)

    expect(page).to have_selector("h1", text: "Occupation Standard for Mechanic")

    expect(page).to have_selector("dt", text: "Occupation")
    expect(page).to have_selector("dt", text: "Url")
    expect(page).to have_selector("dt", text: "Registration agency")
    expect(page).to have_selector("dt", text: "Rapids code")
    expect(page).to have_selector("dt", text: "Onet code")
    expect(page).to have_selector("dt", text: "Created at")
    expect(page).to have_selector("dt", text: "Updated at")

    expect(page).to have_selector("dd", text: occupation_standard.occupation.title)
    expect(page).to have_selector("dd", text: occupation_standard.url)
    expect(page).to have_selector("dd", text: occupation_standard.registration_agency)
    expect(page).to have_selector("dd", text: occupation_standard.rapids_code)
    expect(page).to have_selector("dd", text: occupation_standard.onet_code)
    expect(page).to have_selector("dd", text: occupation_standard.created_at)
    expect(page).to have_selector("dd", text: occupation_standard.updated_at)

    expect(page).to have_selector("h3", text: "Related Instructions")

    expect(page).to have_columnheader("Title")
    expect(page).to have_columnheader("Sort Order")
    expect(page).to have_columnheader("Hours")
    expect(page).to have_columnheader("Elective")

    expect(page).to have_selector("h3", text: "Work Processes")

    expect(page).to have_columnheader("Title")
    expect(page).to have_columnheader("Sort Order")
    expect(page).to have_columnheader("Description")
    expect(page).to have_columnheader("Default Hours")
    expect(page).to have_columnheader("Minimum Hours")
    expect(page).to have_columnheader("Maximum Hours")

    expect(page).to have_link("Edit", href: edit_admin_occupation_standard_path(occupation_standard))
  end

  it "allows for occupation standard not linked to an occupation", :admin do
    occupation_standard = create(:occupation_standard, occupation: nil)
    create(:data_import, occupation_standard: occupation_standard)
    admin = create(:admin)

    login_as admin
    visit admin_occupation_standard_path(occupation_standard)

    expect(page).to have_selector("h1", text: "Occupation Standard for #{occupation_standard.title}")
    expect(page).to have_selector("dt", text: "Occupation")
  end
end
