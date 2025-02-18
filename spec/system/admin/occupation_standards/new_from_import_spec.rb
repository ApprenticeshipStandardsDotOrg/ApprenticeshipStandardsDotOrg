require "rails_helper"

RSpec.describe "admin/occupation_standards/new?import_id=?" do
  context "when document is ready to be converted" do
    it "allows admin user to  occupation_standard", :admin, :js do
      import = create(:imports_pdf)
      registration_agency = create(:registration_agency)
      admin = create(:admin)
      mock_json_response = File.read("spec/fixtures/files/open_ai.json")
      open_ai_import = create(
        :open_ai_import,
        import: import,
        occupation_standard: nil,
        response: mock_json_response
      )

      login_as admin
      visit new_admin_occupation_standard_path(import_id: import.id)

      expect(page).to have_field("Title", with: "Hair Stylist")
      expect(page).to have_field("Existing title", with: "Cosmetologist")
      expect(page).to have_field("ONET code", with: "39-5012.00")
      expect(page).to have_field("RAPIDS code", with: "0096CB")
      expect(page).to have_select("Status", selected: "Importing")
      expect(page).to have_select("OJT type", selected: "Competency")

      fill_in_selectize "occupation_standard_registration_agency_id", with: registration_agency

      within_fieldset("Work processes") do
        expect(page).to have_content("Clean facilities or work areas")

        within(".nested-fields-for-work-processes") do
          expect(page).to have_field("Title", with: "Clean facilities or work areas")
          expect(page).to have_field("Default hours", with: "80")
          expect(page).to have_field("Maximum hours", with: "100")
          expect(page).to have_field("Minimum hours", with: "80")

          within_fieldset("Competencies") do
            expect(page).to have_content("Shampoo, rinse, condition, and dry hair and scalp or hairpieces with water, liquid soap, or other solutions.")

            within(".nested-fields-for-competencies") do
              expect(page).to have_field("Title", with: "Shampoo, rinse, condition, and dry hair and scalp or hairpieces with water, liquid soap, or other solutions.")
            end
          end
        end
      end

      click_button "Create Occupation standard"

      expect(page).to have_content("Occupation standard was successfully created.")
    end
  end

  context "when document was not previously processed and it's not ready to be converted" do
    it "redirects user to import pdf show page", :admin do
      import = create(:imports_pdf)
      admin = create(:admin)

      login_as admin
      visit new_admin_occupation_standard_path(import_id: import.id)

      expect(page).to have_content "You must prepare the document by clicking Convert with AI"
      expect(page).to have_current_path admin_import_path(import)
    end
  end
end

# From https://stackoverflow.com/a/77789522
def fill_in_selectize(key, options = {})
  find("##{key} + .selectize-control .selectize-input input").native.send_keys(options[:with])
  find(:xpath, "//div[@data-selectable and contains(., '#{options[:with]}')]").click
end
