require "rails_helper"

RSpec.describe "OccupationStandardShowModal", js: true do
  context "when user accepts cookies" do
    it "shows modal until second visit" do
      clear_cookies!

      occupation_standard = create(:occupation_standard, :with_data_import)

      visit guest_root_path

      within_dialog "Cookie Notice" do
        click_on "Accept"
      end

      visit occupation_standard_path(occupation_standard)
      expect(page).to_not have_modal("Apprenticeship Standard Survey")

      visit occupation_standard_path(occupation_standard)
      expect(page).to have_modal("Apprenticeship Standard Survey")
    end

    context "user dismisses modal" do
      it "hides modal and will show modal again according to recurrences" do
        clear_cookies!

        occupation_standard = create(:occupation_standard, :with_data_import)

        visit guest_root_path

        within_dialog "Cookie Notice" do
          click_on "Accept"
        end

        # First visit: no modal
        visit occupation_standard_path(occupation_standard)
        expect(page).to_not have_modal("Apprenticeship Standard Survey")

        # Second visit: modal appears
        visit occupation_standard_path(occupation_standard)
        expect(page).to have_modal("Apprenticeship Standard Survey")

        dismiss_modal
        expect(page).to_not have_modal("Apprenticeship Standard Survey")

        # Third visit: no modal since first time entry has not passed

        visit occupation_standard_path(occupation_standard)
        expect(page).to_not have_modal("Apprenticeship Standard Survey")

        # Fourth visit: enough time has passed and modal must appear (more than 7 days)
        travel 10.days do
          visit occupation_standard_path(occupation_standard)
          expect(page).to have_modal("Apprenticeship Standard Survey")

          dismiss_modal
          expect(page).to_not have_modal("Apprenticeship Standard Survey")

          # Fifth visit: no modal since second time entry has not passed
          visit occupation_standard_path(occupation_standard)
          expect(page).to_not have_modal("Apprenticeship Standard Survey")
        end

        # Sixth visit: enough time has passed and modal must appear (more than a month)
        travel 1.month + 15.days do
          visit occupation_standard_path(occupation_standard)
          expect(page).to have_modal("Apprenticeship Standard Survey")

          dismiss_modal
          expect(page).to_not have_modal("Apprenticeship Standard Survey")

          # Seventh visit: no modal since first time entry has not passed
          visit occupation_standard_path(occupation_standard)
          expect(page).to_not have_modal("Apprenticeship Standard Survey")
        end

        # Eight visit: enough time has passed and modal must appear (more than three months)
        travel 5.month do
          visit occupation_standard_path(occupation_standard)
          expect(page).to have_modal("Apprenticeship Standard Survey")

          dismiss_modal
          expect(page).to_not have_modal("Apprenticeship Standard Survey")

          # Nineth and upcoming visits: no modal since we have already dismissed 3 times
          visit occupation_standard_path(occupation_standard)
          expect(page).to_not have_modal("Apprenticeship Standard Survey")
        end

        # Let's check in two years
        travel 2.years do
          visit occupation_standard_path(occupation_standard)
          expect(page).to_not have_modal("Apprenticeship Standard Survey")
        end
      end

      context "users sends information" do
        it "does not show the modal ever again" do
          clear_cookies!

          occupation_standard = create(:occupation_standard, :with_data_import)

          visit guest_root_path

          within_dialog "Cookie Notice" do
            click_on "Accept"
          end

          # First visit: no modal
          visit occupation_standard_path(occupation_standard)
          expect(page).to_not have_modal("Apprenticeship Standard Survey")

          # Second visit: modal appears
          visit occupation_standard_path(occupation_standard)
          expect(page).to have_modal("Apprenticeship Standard Survey")

          within_modal "Apprenticeship Standard Survey" do
            fill_in "Name", with: "Bob"
            fill_in "Email", with: "bob@apprenticeshipstandars.org"
            fill_in "Organization", with: "Apprenticeship Standards"
            click_button "Submit"
          end

          expect(page).to_not have_modal("Apprenticeship Standard Survey")

          # If we visit the site in 10 days, modal must not appear
          travel 10.days do
            visit occupation_standard_path(occupation_standard)
            expect(page).to_not have_modal("Apprenticeship Standard Survey")
          end

          # If we visit the site in a year, modal must not appear
          travel 1.year do
            visit occupation_standard_path(occupation_standard)
            expect(page).to_not have_modal("Apprenticeship Standard Survey")
          end
        end
      end
    end
  end

  context "when users rejects cookies" do
    it "never shows the modal" do
      clear_cookies!

      occupation_standard = create(:occupation_standard, :with_data_import)

      visit guest_root_path

      within_dialog "Cookie Notice" do
        click_on "Reject"
      end

      visit occupation_standard_path(occupation_standard)
      expect(page).to_not have_modal("Apprenticeship Standard Survey")

      visit occupation_standard_path(occupation_standard)
      expect(page).to_not have_modal("Apprenticeship Standard Survey")
    end
  end

  def dismiss_modal
    find("button#dismiss-modal").click
  end

  def clear_cookies!
    visit occupation_standards_path
    Capybara.reset_sessions!
  end
end
