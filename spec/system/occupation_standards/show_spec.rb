require "rails_helper"

RSpec.describe "occupation_standards/show" do
  it "displays title" do
    occupation_standard = create(:occupation_standard, :with_data_import)

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_content occupation_standard.title
  end

  it "removes HTML tags from competencies title" do
    occupation_standard = create(:occupation_standard, :with_data_import)
    work_process = create(
      :work_process,
      occupation_standard: occupation_standard,
      title: "Sample Work Process"
    )
    create(
      :competency,
      work_process: work_process,
      title: "<html>Title with<b> HTML</b><html>"
    )

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_content "Title with HTML"
  end
end
