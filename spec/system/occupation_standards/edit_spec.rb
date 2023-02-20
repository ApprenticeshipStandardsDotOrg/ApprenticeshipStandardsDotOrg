require "rails_helper"

RSpec.describe "occupation_standards/edit" do
  it "allows admin user to edit occupation_standard", :admin do
    occupation_standard = create(:occupation_standard)
    admin = create(:admin)

    login_as admin
    visit occupation_standards_path

    within("main") do
      click_on "Edit"
    end

    expect(page).to have_content("Edit #{occupation_standard.title}")
    fill_in "Title", with: "New title"
    fill_in "ONET Code", with: "2345.67"
    fill_in "RAPIDS Code", with: "98765"
    select "In Review", from: "Status"
    click_on "Update"

    within("h1") do
      expect(page).to have_content("Occupation Standard for New title")
    end
    expect(page).to have_content "2345.67"
    expect(page).to have_content "98765"
    expect(page).to have_content "In Review"
  end
end
