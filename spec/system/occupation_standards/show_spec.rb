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

  it "shows registration date if available" do
    occupation_standard = create(:occupation_standard, :with_data_import, registration_date: Date.parse("October 17, 1989"))

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_text "Registered 1989"
  end

  it "shows latest updated date if available" do
    occupation_standard = create(:occupation_standard, :with_data_import, latest_update_date: Date.parse("October 17, 1989"))

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_text "Updated 1989"
  end

  it "shows only redacted document if both public and redacted are available" do
    occupation_standard = create(:occupation_standard, :with_data_import, :with_redacted_document)
    allow_any_instance_of(OccupationStandard).to receive(:public_document?).and_return(true)

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_text "View Redacted Document"
    expect(page).to have_no_text "View Original Document"
  end

  it "shows public document if standards import comes from a public source" do
    occupation_standard = create(:occupation_standard, :with_data_import)
    allow_any_instance_of(OccupationStandard).to receive(:public_document?).and_return(true)

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_text "View Original Document"
    expect(page).to have_no_text "View Redacted Document"
  end

  it "shows message if neither public nor redacted document are available" do
    occupation_standard = create(:occupation_standard, :with_data_import)
    allow_any_instance_of(OccupationStandard).to receive(:public_document?).and_return(false)

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_text "No documents available at the moment"
    expect(page).to have_no_text "View Original Document"
    expect(page).to have_no_text "View Redacted Document"
  end
end
