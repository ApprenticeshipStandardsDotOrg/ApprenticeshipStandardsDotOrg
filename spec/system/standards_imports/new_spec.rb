require "rails_helper"

RSpec.describe "standards_imports/new" do
  it "create a new standards_imports record" do
    visit new_standards_import_path
    fill_in "Name", with: "Mickey Mouse"
    fill_in "Email", with: "mickey@example.com"
    fill_in "Organization", with: "Disney"
    fill_in "Notes", with: "a" * 500
    attach_file "Files", ["spec/fixtures/files/pixel1x1.jpg", "spec/fixtures/files/pixel1x1.pdf", "spec/fixtures/files/pixel1x1-2.jpg"]

    click_on "Upload"

    expect(page).to have_text "Mickey Mouse"
    expect(page).to have_text "mickey@example.com"
    expect(page).to have_text "Disney"
    expect(page).to have_text "a" * 500
    expect(page).to have_text "pixel1x1.jpg"
    expect(page).to have_text "pixel1x1.pdf"
    expect(page).to have_text "pixel1x1-2.jpg"

    si = StandardsImport.last
    expect(si.name).to eq "Mickey Mouse"
    expect(si.email).to eq "mickey@example.com"
    expect(si.organization).to eq "Disney"
    expect(si.notes).to eq "a" * 500
    expect(si.files.count).to eq 3
  end
end
