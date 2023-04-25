require "rails_helper"

RSpec.describe "admin/source_files/index", :admin do
  context "when admin user" do
    it "displays status, link to file, and option to convert or edit" do
      create(:standards_import, :with_files)
      admin = create :admin

      login_as admin
      visit admin_source_files_path

      source_file = SourceFile.last
      expect(page).to have_link("New source file", href: new_standards_import_path)
      expect(page).to have_link("pixel1x1.pdf")

      expect(page).to have_content("Pending").once
      expect(page).to have_link("Convert", href: new_admin_source_file_data_import_path(source_file))
      expect(page).to have_link("Edit", href: edit_admin_source_file_path(source_file))
      expect(page).to have_link("Destroy", href: admin_source_file_path(source_file))

      within("nav") do
        expect(page).to have_link "Source Files", href: root_path
        expect(page).to have_link "Users", href: admin_users_path
        expect(page).to have_link "API Keys", href: admin_api_keys_path
        expect(page).to have_link "Occupation Standards", href: admin_occupation_standards_path
        expect(page).to have_link "Edit account", href: edit_user_registration_path
        expect(page).to have_link "Logout", href: destroy_user_session_path
        expect(page).to have_link "Sidekiq", href: "/sidekiq"
        expect(page).to have_link "Swagger", href: "/api-docs"
      end
    end

    it "can search on filename" do
      create(:standards_import, :with_files)
      source_file = SourceFile.last
      admin = create :admin

      login_as admin
      visit admin_source_files_path(search: "pixel")

      expect(page).to have_link("pixel1x1.pdf")
      expect(page).to have_link("New source file", href: new_standards_import_path)

      expect(page).to have_content("Pending").once
      expect(page).to have_link("Convert", href: new_admin_source_file_data_import_path(source_file))
      expect(page).to have_link("Edit", href: edit_admin_source_file_path(source_file))
      expect(page).to have_link("Destroy", href: admin_source_file_path(source_file))

      visit admin_source_files_path(search: "foobar")

      expect(page).to have_link("New source file", href: new_standards_import_path)
      expect(page).to_not have_link("pixel1x1.pdf")
      expect(page).to_not have_content("Pending")
      expect(page).to_not have_link("Convert")
      expect(page).to_not have_link("Edit", href: edit_admin_source_file_path(source_file))
      expect(page).to_not have_link("Destroy")
    end
  end

  context "when converter" do
    it "displays status, link to file, and option to convert or edit" do
      create(:standards_import, :with_files)
      admin = create(:user, :converter)

      login_as admin
      visit admin_source_files_path

      source_file = SourceFile.last
      expect(page).to have_link("New source file", href: new_standards_import_path)
      expect(page).to have_link("pixel1x1.pdf")

      expect(page).to have_content("Pending").once
      expect(page).to have_link("Convert", href: new_admin_source_file_data_import_path(source_file))
      expect(page).to_not have_link("Edit", href: edit_admin_source_file_path(source_file))
      expect(page).to_not have_link("Destroy")

      within("nav") do
        expect(page).to have_link "Source Files", href: root_path
        expect(page).to have_link "Edit account", href: edit_user_registration_path
        expect(page).to have_link "Logout", href: destroy_user_session_path
        expect(page).to_not have_link "Sidekiq"
        expect(page).to_not have_link "Swagger"
      end
    end

    it "can search on filename" do
      create(:standards_import, :with_files)
      source_file = SourceFile.last
      admin = create(:user, :converter)

      login_as admin
      visit admin_source_files_path(search: "pixel")

      expect(page).to have_link("pixel1x1.pdf")
      expect(page).to have_link("New source file", href: new_standards_import_path)

      expect(page).to have_content("Pending").once
      expect(page).to have_link("Convert", href: new_admin_source_file_data_import_path(source_file))
      expect(page).to_not have_link("Edit", href: edit_admin_source_file_path(source_file))
      expect(page).to_not have_link("Destroy")

      visit admin_source_files_path(search: "foobar")

      expect(page).to have_link("New source file", href: new_standards_import_path)
      expect(page).to_not have_link("pixel1x1.pdf")
      expect(page).to_not have_content("Pending")
      expect(page).to_not have_link("Convert")
      expect(page).to_not have_link("Edit", href: edit_admin_source_file_path(source_file))
      expect(page).to_not have_link("Destroy")
    end
  end
end
