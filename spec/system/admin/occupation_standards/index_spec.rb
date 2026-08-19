require "rails_helper"

RSpec.describe "admin/occupation_standards/index", :admin do
  it "can search by agency" do
    alabama = create(:state, name: "Alabama")
    al_reg_agency = create(:registration_agency, :saa, state: alabama)
    create(:occupation_standard, registration_agency: al_reg_agency)

    california = State.find_by(name: "California") || create(:state, name: "California")
    ca_reg_agency = create(:registration_agency, :oa, state: california)
    create(:occupation_standard, registration_agency: ca_reg_agency)

    admin = create(:admin)

    login_as admin
    visit admin_occupation_standards_path

    expect(page).to have_text("Alabama (SAA)")
    expect(page).to have_text("California (OA)")

    visit admin_occupation_standards_path(search: "alabama")

    expect(page).to have_text("Alabama (SAA)")
    expect(page).to_not have_text("California (OA)")
  end

  it "can search by occupation" do
    coppersmith = create(:occupation, title: "COPPERSMITH")
    create(:occupation_standard, occupation: coppersmith, title: "os 1")

    mechanic = create(:occupation, title: "Mechanic")
    create(:occupation_standard, occupation: mechanic, title: "os 2")

    admin = create(:admin)

    login_as admin
    visit admin_occupation_standards_path

    expect(page).to have_text("COPPERSMITH")
    expect(page).to have_text("Mechanic")

    visit admin_occupation_standards_path(search: "copper")

    expect(page).to have_text("COPPERSMITH")
    expect(page).to_not have_text("Mechanic")
  end

  it "will search both occupation and occupation standard for RAPIS code" do
    coppersmith = create(:occupation, title: "COPPERSMITH", rapids_code: "1234")
    create(:occupation_standard, occupation: coppersmith, title: "os 1", rapids_code: "4567")

    mechanic = create(:occupation, title: "Mechanic", rapids_code: "9876")
    create(:occupation_standard, occupation: mechanic, title: "os 2", rapids_code: "1234")

    medical_asst = create(:occupation, title: "Medical Assistant", rapids_code: "1111")
    create(:occupation_standard, occupation: medical_asst, title: "os 3", rapids_code: "1111")

    admin = create(:admin)

    login_as admin
    visit admin_occupation_standards_path

    expect(page).to have_text("COPPERSMITH")
    expect(page).to have_text("Mechanic")
    expect(page).to have_text("Medical Assistant")

    visit admin_occupation_standards_path(search: "1234")

    expect(page).to have_text("COPPERSMITH")
    expect(page).to have_text("Mechanic")
    expect(page).to_not have_text("Medical Assistant")
  end

  it "shows AI label when an occupation was converted using AI" do
    open_ai_import = create(:open_ai_import, :with_pdf_import)
    open_ai_import.occupation_standard

    admin = create(:admin)

    login_as admin
    visit admin_occupation_standards_path

    expect(page).to have_text("AI Converted")
  end

  it "can filter by source" do
    ai_standard = create(:occupation_standard, title: "AI Standard", source: :ai_conversion)
    create(:occupation_standard, title: "Manual Standard", source: :manual_upload)
    admin = create(:admin)

    login_as admin
    visit admin_occupation_standards_path

    expect(page).to have_link(
      "AI Conversion",
      href: admin_occupation_standards_path(search: "source:ai_conversion"),
      visible: :all
    )

    expect(page).to have_link(
      "Sample CSV Report",
      href: sample_set_report_admin_occupation_standards_path(format: :csv, search: "sample_set:true")
    )
    expect(page).to have_selector("summary[aria-label='Sample CSV report field definitions']", text: "?")
    expect(page).to have_selector("dt", text: "manual_wp_count", visible: :all)
    expect(page).to have_selector("dd", text: "AI extracted work process count.", visible: :all)

    visit admin_occupation_standards_path(search: "source:ai_conversion")

    expect(page).to have_text(ai_standard.title)
    expect(page).to_not have_text("Manual Standard")

    expect(page).to have_link(
      "Sample CSV Report",
      href: sample_set_report_admin_occupation_standards_path(format: :csv, search: "source:ai_conversion sample_set:true")
    )
  end
end
