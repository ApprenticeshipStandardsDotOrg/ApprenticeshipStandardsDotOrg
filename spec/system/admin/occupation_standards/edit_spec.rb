require "rails_helper"

RSpec.describe "admin/occupation_standards/edit" do
  it "allows admin user to edit occupation_standard", :admin do
    data_import = create(:data_import)
    occupation_standard = data_import.occupation_standard
    admin = create(:admin)

    login_as admin
    visit edit_admin_occupation_standard_path(occupation_standard)

    expect(page).to have_selector("h1", text: "Edit Mechanic")
    expect(page).to have_field("Title")
    expect(page).to have_field("ONET code")
    expect(page).to have_field("RAPIDS code")
    expect(page).to have_select("Status")

    fill_in "Title", with: "New title"
    fill_in "ONET code", with: "2345.67"
    fill_in "RAPIDS code", with: "98765"
    select "In Review", from: "Status"
    click_on "Update"

    within("h1") do
      expect(page).to have_content("New title")
    end
    expect(page).to have_content "2345.67"
    expect(page).to have_content "98765"
    expect(page).to have_content "In Review"
  end

  it "allows for occupation standard not linked to an occupation", :admin do
    occupation_standard = create(:occupation_standard, occupation: nil, title: "Mechanic")
    create(:data_import, occupation_standard: occupation_standard)
    admin = create(:admin)

    login_as admin
    visit edit_admin_occupation_standard_path(occupation_standard)

    expect(page).to have_selector("h1", text: "Edit Mechanic")
  end

  describe "work processes" do
    it "allows an admin user to add a new work process to an occupation standard", :admin, js: true do
      occupation_standard = create(:occupation_standard)
      admin = create(:admin)

      login_as admin
      visit edit_admin_occupation_standard_path(occupation_standard)

      within_fieldset("Work processes") do
        click_on "Add Work Process"

        within(".nested-fields") do
          page.find("details").click
          fill_in "Title", with: "New Work Process"
        end
      end

      click_on "Update Occupation standard"

      expect(page).to have_content("New Work Process")
      expect(occupation_standard.work_processes.count).to eq 1
    end

    it "allows an admin user to remove a new work process from an occupation standard", :admin, js: true do
      occupation_standard = create(:occupation_standard, :with_work_processes)
      admin = create(:admin)

      login_as admin
      visit edit_admin_occupation_standard_path(occupation_standard)

      within_fieldset("Work processes") do
        click_on "Remove Work Process"
      end

      click_on "Update Occupation standard"

      expect(page).not_to have_content("Work Process #")
      expect(occupation_standard.work_processes.count).to eq 0
    end

    context "with competencies" do
      it "allows an admin user to add a new competency to a work process", :admin, js: true do
        occupation_standard = create(:occupation_standard, :with_work_processes)
        admin = create(:admin)

        login_as admin
        visit edit_admin_occupation_standard_path(occupation_standard)

        within_fieldset("Work processes") do
          within_fieldset("Competencies") do
            click_on "Add Competency"

            within(".nested-fields") do
              fill_in "Title", with: "New Competency"
            end
          end
        end
        click_on "Update Occupation standard"

        expect(page).to have_content("1 competencies")
        expect(occupation_standard.work_processes.first.competencies.count).to eq 1
      end

      it "allows an admin user to remove a competency from a work process", :admin, js: true do
        occupation_standard = create(:occupation_standard, :with_work_processes_and_competencies)
        admin = create(:admin)

        login_as admin
        visit edit_admin_occupation_standard_path(occupation_standard)

        within_fieldset("Work processes") do
          within_fieldset("Competencies") do
            click_on "Remove Competency"
          end
        end

        click_on "Update Occupation standard"

        expect(page).not_to have_content("Competency Title")
        expect(occupation_standard.work_processes.first.competencies.count).to eq 0
      end
    end
  end

  describe "related instructions" do
    it "allows an admin user to add a new related to an occupation standard", :admin, js: true do
      occupation_standard = create(:occupation_standard)
      admin = create(:admin)

      login_as admin
      visit edit_admin_occupation_standard_path(occupation_standard)

      within_fieldset("Related instructions") do
        click_on "Add Related Instruction"

        within(".nested-fields") do
          fill_in "Title", with: "New Related Instruction"
          fill_in "Description", with: "Description for this related instruction"
          fill_in "Code", with: "RI-101"
          fill_in "Hours", with: "8"
          fill_in "Sort order", with: "1"
        end
      end

      click_on "Update Occupation standard"

      expect(page).to have_content("New Related Instruction")
      expect(occupation_standard.related_instructions.count).to eq 1
    end

    it "allows an admin user to remove a new related instruction from an occupation standard", :admin, js: true do
      occupation_standard = create(:occupation_standard, :with_related_instructions)
      admin = create(:admin)

      login_as admin
      visit edit_admin_occupation_standard_path(occupation_standard)

      within_fieldset("Related instructions") do
        click_on "Remove Related Instruction"
      end

      click_on "Update Occupation standard"

      expect(page).not_to have_content("Related Instruction #")
      expect(occupation_standard.related_instructions.count).to eq 0
    end
  end
end
