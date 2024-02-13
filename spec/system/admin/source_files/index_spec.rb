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

    it "can search on status" do
      create(:source_file, :pending)
      create(:source_file, :completed)
      create(:source_file, :needs_support)
      admin = create(:admin)

      login_as admin
      visit admin_source_files_path

      expect(page).to have_text "Pending"
      expect(page).to have_text "Completed"
      expect(page).to have_text "Needs Support"

      visit admin_source_files_path(search: "needs support")

      expect(page).to_not have_text "Pending"
      expect(page).to_not have_text "Completed"
      expect(page).to have_text "Needs Support"

      visit admin_source_files_path(search: "Needs Support")

      expect(page).to_not have_text "Pending"
      expect(page).to_not have_text "Completed"
      expect(page).to have_text "Needs Support"

      visit admin_source_files_path(search: "needs_support")

      expect(page).to_not have_text "Pending"
      expect(page).to_not have_text "Completed"
      expect(page).to have_text "Needs Support"
    end

    it "can search on organization" do
      create(:standards_import, :with_files, organization: "Google")
      create(:standards_import, :with_files, organization: "Tesla")

      admin = create(:admin)

      login_as admin
      visit admin_source_files_path

      expect(page).to have_text "Google"
      expect(page).to have_text "Tesla"

      visit admin_source_files_path(search: "Google")

      expect(page).to have_text "Google"
      expect(page).to_not have_text "Tesla"
    end

    it "can search on assignee" do
      create(:standards_import, :with_files, organization: "Google")

      converter1 = create(:user, :converter, name: "Mickey")
      create(:source_file, assignee: converter1)

      converter2 = create(:user, :converter, name: "Goofy")
      create(:source_file, assignee: converter2)

      admin = create(:admin)

      login_as admin
      visit admin_source_files_path

      expect(page).to have_text "Google"
      expect(page).to have_text "Mickey"
      expect(page).to have_text "Goofy"

      visit admin_source_files_path(search: "Mickey")

      expect(page).to_not have_text "Google"
      expect(page).to have_text "Mickey"
      expect(page).to_not have_text "Goofy"

      visit admin_source_files_path(search: "goo")

      expect(page).to have_text "Google"
      expect(page).to_not have_text "Mickey"
      expect(page).to have_text "Goofy"
    end

    it "can search on public_document" do
      converter1 = create(:user, :converter, name: "Mickey")
      create(:source_file, assignee: converter1, public_document: true)

      converter2 = create(:user, :converter, name: "Goofy")
      create(:source_file, assignee: converter2, public_document: false)

      admin = create(:admin)

      login_as admin
      visit admin_source_files_path

      expect(page).to have_text "Mickey"
      expect(page).to have_text "Goofy"

      visit admin_source_files_path(search: "public_document:true")

      expect(page).to have_text "Mickey"
      expect(page).to_not have_text "Goofy"

      visit admin_source_files_path(search: "public_document:false")

      expect(page).to_not have_text "Mickey"
      expect(page).to have_text "Goofy"

      visit admin_source_files_path(search: "pd:false")

      expect(page).to_not have_text "Mickey"
      expect(page).to_not have_text "Goofy"
    end

    it "can claim a source file" do
      converter = create(:user, :converter, name: "Mickey Mouse")
      create(:source_file)
      create(:source_file, assignee: converter)
      admin = create(:admin, name: "Amy Applebaum")

      login_as admin
      visit admin_source_files_path

      expect(page).to have_text "Mickey Mouse"
      expect(page).to have_button("Claim").once

      click_button "Claim"

      expect(page).to have_text "Amy Applebaum"
      expect(page).to_not have_button "Claim"
    end
  end

  context "when converter" do
    it "displays status, link to file, and option to convert or edit" do
      create(:standards_import, :with_files)
      admin = create(:user, :converter)

      login_as admin
      visit admin_source_files_path

      source_file = SourceFile.last
      expect(page).to_not have_link("New source file", href: new_standards_import_path)
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
      expect(page).to_not have_link("New source file", href: new_standards_import_path)

      expect(page).to have_content("Pending").once
      expect(page).to have_link("Convert", href: new_admin_source_file_data_import_path(source_file))
      expect(page).to_not have_link("Edit", href: edit_admin_source_file_path(source_file))
      expect(page).to_not have_link("Destroy")

      visit admin_source_files_path(search: "foobar")

      expect(page).to_not have_link("New source file", href: new_standards_import_path)
      expect(page).to_not have_link("pixel1x1.pdf")
      expect(page).to_not have_content("Pending")
      expect(page).to_not have_link("Convert")
      expect(page).to_not have_link("Edit", href: edit_admin_source_file_path(source_file))
      expect(page).to_not have_link("Destroy")
    end

    it "can claim a source file" do
      create(:source_file)
      admin = create(:user, :converter, name: "Amy Applebaum")

      login_as admin
      visit admin_source_files_path

      expect(page).to have_button("Claim").once

      click_button "Claim"

      expect(page).to have_text "Amy Applebaum"
      expect(page).to_not have_button "Claim"
    end

    it "shows a link to filter files ready for redaction" do
      source_file_with_all_conditions = create(:source_file,
        :pdf,
        :without_redacted_source_file,
        :completed)

      source_file_not_complete = create(:source_file,
        :pdf,
        :without_redacted_source_file,
        :pending)

      source_file_with_docx_attachment = create(:source_file,
        :docx,
        :without_redacted_source_file,
        :completed)

      source_file_with_redacted_source_file = create(:source_file,
        :pdf,
        :with_redacted_source_file,
        :completed)

      admin = create(:user, :converter)

      login_as admin
      visit admin_source_files_path

      expect(page).to have_link(
        source_file_with_all_conditions.filename,
        href: admin_source_file_path(source_file_with_all_conditions.id)
      )
      expect(page).to have_link(
        source_file_not_complete.filename,
        href: admin_source_file_path(source_file_not_complete.id)
      )
      expect(page).to have_link(
        source_file_with_docx_attachment.filename,
        href: admin_source_file_path(source_file_with_docx_attachment.id)
      )
      expect(page).to have_link(
        source_file_with_redacted_source_file.filename,
        href: admin_source_file_path(source_file_with_redacted_source_file.id)
      )

      click_link "Needs Redaction"

      expect(page).to have_link(
        source_file_with_all_conditions.filename,
        href: admin_source_file_path(source_file_with_all_conditions.id)
      )
      expect(page).to_not have_link(
        source_file_not_complete.filename,
        href: admin_source_file_path(source_file_not_complete.id)
      )
      expect(page).to_not have_link(
        source_file_with_docx_attachment.filename,
        href: admin_source_file_path(source_file_with_docx_attachment.id)
      )
      expect(page).to_not have_link(
        source_file_with_redacted_source_file.filename,
        href: admin_source_file_path(source_file_with_redacted_source_file.id)
      )

      click_link "Show All"

      expect(page).to have_link(
        source_file_with_all_conditions.filename,
        href: admin_source_file_path(source_file_with_all_conditions.id)
      )
      expect(page).to have_link(
        source_file_not_complete.filename,
        href: admin_source_file_path(source_file_not_complete.id)
      )
      expect(page).to have_link(
        source_file_with_docx_attachment.filename,
        href: admin_source_file_path(source_file_with_docx_attachment.id)
      )
      expect(page).to have_link(
        source_file_with_redacted_source_file.filename,
        href: admin_source_file_path(source_file_with_redacted_source_file.id)
      )
    end

    it "shows a link to filter files already redacted" do
      source_file_without_redacted_source_file = create(
        :source_file,
        :docx,
        :without_redacted_source_file
      )

      source_file_with_redacted_source_file = create(:source_file, :with_redacted_source_file)

      admin = create(:user, :converter)

      login_as admin
      visit admin_source_files_path

      expect(page).to have_link(
        source_file_without_redacted_source_file.filename,
        href: admin_source_file_path(source_file_without_redacted_source_file.id)
      )
      expect(page).to have_link(
        source_file_with_redacted_source_file.filename,
        href: admin_source_file_path(source_file_with_redacted_source_file.id)
      )

      click_link "Redacted"

      expect(page).to have_link(
        source_file_with_redacted_source_file.filename,
        href: admin_source_file_path(source_file_with_redacted_source_file.id)
      )
      expect(page).to_not have_link(
        source_file_without_redacted_source_file.filename,
        href: admin_source_file_path(source_file_without_redacted_source_file.id)
      )

      click_link "Show All"

      expect(page).to have_link(
        source_file_without_redacted_source_file.filename,
        href: admin_source_file_path(source_file_without_redacted_source_file.id)
      )
      expect(page).to have_link(
        source_file_with_redacted_source_file.filename,
        href: admin_source_file_path(source_file_with_redacted_source_file.id)
      )
    end
  end
end
