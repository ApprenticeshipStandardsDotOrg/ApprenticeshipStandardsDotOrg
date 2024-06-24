require "rails_helper"

RSpec.describe "admin/imports/show", :admin do
  context "when Imports::Pdf" do
    context "when admin" do
      it "does not have button for needing support but has data import and redact buttons" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        import = create(:imports_pdf)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_text "Imports::Pdf"
        expect(page).to_not have_button "Needs support"
        expect(page).to have_link "New data import", href: new_admin_import_data_import_path(import)
        expect(page).to_not have_link "Redact document", href: new_admin_import_redact_file_path(import)
        expect(page).to have_link "Edit", href: edit_admin_import_path(import)
        expect(page).to have_link "Destroy"
        expect(page).to have_text "Data import"
        expect(page).to have_text "Courtesy notification"
        expect(page).to have_text "Parent"
        expect(page).to have_text "Associated occupation standards"

        stub_feature_flag(:show_imports_in_administrate, false)
      end

      it "displays data imports with the correct link" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        import = create(:imports_pdf)
        data_import = create(:data_import, import: import)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_text "occupation-standards-template.xlsx"
        expect(page).to have_link "Edit", href: edit_admin_import_data_import_path(import, data_import)

        stub_feature_flag(:show_imports_in_administrate, false)
      end

      context "when import is not public document and completed" do
        it "shows redact document link" do
          stub_feature_flag(:show_imports_in_administrate, true)

          admin = create(:admin)
          import = create(:imports_pdf, public_document: false, status: :completed)

          login_as admin
          visit admin_import_path(import)

          expect(page).to have_link "Redact document", href: new_admin_import_redact_file_path(import)

          stub_feature_flag(:show_imports_in_administrate, false)
        end
      end

      it "allows admin to remove a redacted file" do
        admin = create(:admin)
        import = create(:imports_pdf, :with_redacted_pdf)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_text import.redacted_pdf.filename

        expect(page).to have_link(
          "Remove",
          href: redacted_import_admin_import_path(
            import,
            attachment_id: import.redacted_pdf.id
          )
        )

        click_link "Remove"

        expect(page).to_not have_text import.redacted_pdf.filename
        expect(page).to have_text "No attachment"
        expect(page).to_not have_link "Remove"
      end
    end

    context "when converter" do
      it "has button for needing support, data imports, and redact buttons" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin, :converter)
        import = create(:imports_pdf, status: :pending)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_button "Needs support"
        expect(page).to have_link "New data import", href: new_admin_import_data_import_path(import)
        expect(page).to_not have_link "Redact document", href: new_admin_import_redact_file_path(import)
        expect(page).to have_text "Data imports"
        expect(page).to_not have_link "Edit", href: edit_admin_import_path(import)
        expect(page).to_not have_link "Destroy"
        expect(page).to_not have_text "Courtesy notification"
        expect(page).to_not have_text "Parent"
        expect(page).to_not have_text "Child"
        expect(page).to_not have_text "Type"
        expect(page).to_not have_text "Imports::Pdf"

        click_on "Needs support"

        expect(page).to have_text "needs_support"
        expect(import.reload).to be_needs_support

        stub_feature_flag(:show_imports_in_administrate, false)
      end

      context "when import is not public document and completed" do
        it "shows redact document link" do
          stub_feature_flag(:show_imports_in_administrate, true)

          admin = create(:admin, :converter)
          import = create(:imports_pdf, public_document: false, status: :completed)

          login_as admin
          visit admin_import_path(import)

          expect(page).to have_link "Redact document", href: new_admin_import_redact_file_path(import)

          stub_feature_flag(:show_imports_in_administrate, false)
        end
      end

      it "has button for archiving" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin, :converter)
        import = create(:imports_pdf, status: :pending)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_button "Archive"

        click_on "Archive"

        expect(page).to have_text "archived"
        expect(import.reload).to be_archived

        stub_feature_flag(:show_imports_in_administrate, false)
      end

      it "can view the associated occupation standards" do
        stub_feature_flag(:show_imports_in_administrate, true)
        stub_feature_flag(:similar_programs_elasticsearch, false)

        admin = create(:admin, :converter)
        occupation_standard = create(:occupation_standard, title: "Mechanic")
        create(:work_process, occupation_standard: occupation_standard, title: "WP1")
        import = create(:imports_pdf, status: :pending)
        create(:data_import, import: import, occupation_standard: occupation_standard)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_text "Associated occupation standards"

        click_on "Mechanic", match: :first

        expect(page).to have_text "Mechanic"
        expect(page).to have_text "WP1"

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end

  context "when Imports::Uncategorized type" do
    context "when admin" do
      it "does not have buttons for needing support, data import or redact" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        import = create(:imports_uncategorized)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_text "Imports::Uncategorized"
        expect(page).to_not have_button "Needs support"
        expect(page).to_not have_link "New data import"
        expect(page).to_not have_link "Redact document"
        expect(page).to have_link "Edit", href: edit_admin_import_path(import)
        expect(page).to have_link "Destroy"
        expect(page).to have_text "Data import"
        expect(page).to have_text "Courtesy notification"
        expect(page).to have_text "Parent"
        expect(page).to have_text "Child"
        expect(page).to have_text "Type"
        expect(page).to have_text "Associated occupation standards"

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end

  context "when Imports::Doc type" do
    context "when admin" do
      it "does not have buttons for needing support, data import or redact" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        import = create(:imports_doc)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_text "Imports::Doc"
        expect(page).to_not have_button "Needs support"
        expect(page).to_not have_link "New data import"
        expect(page).to_not have_link "Redact document"
        expect(page).to have_link "Edit", href: edit_admin_import_path(import)
        expect(page).to have_link "Destroy"

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end

  context "when Imports::Docx type" do
    context "when admin" do
      it "does not have buttons for needing support, data import or redact" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        import = create(:imports_docx)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_text "Imports::Doc"
        expect(page).to_not have_button "Needs support"
        expect(page).to_not have_link "New data import"
        expect(page).to_not have_link "Redact document"
        expect(page).to have_link "Edit", href: edit_admin_import_path(import)
        expect(page).to have_link "Destroy"

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end

  context "when Imports::DocxListing type" do
    context "when admin" do
      it "does not have buttons for needing support, data import or redact" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        import = create(:imports_docx_listing)

        login_as admin
        visit admin_import_path(import)

        expect(page).to have_text "Imports::Doc"
        expect(page).to_not have_button "Needs support"
        expect(page).to_not have_link "New data import"
        expect(page).to_not have_link "Redact document"
        expect(page).to have_link "Edit", href: edit_admin_import_path(import)
        expect(page).to have_link "Destroy"

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end
end
