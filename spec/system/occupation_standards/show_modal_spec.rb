require "rails_helper"

RSpec.describe "OccupationStandardShowModal" do
  it "shows modal until second visit" do
    occupation_standard = create(:occupation_standard, :with_data_import)

    visit occupation_standard_path(occupation_standard)
    expect(page).to_not have_modal("Apprenticeship Standard Survey")

    visit occupation_standard_path(occupation_standard)
    expect(page).to have_modal("Apprenticeship Standard Survey")
  end

  context "user dismisses modal", js: true do
    it "hides modal and will show modal again according to recurrences" do
      occupation_standard = create(:occupation_standard, :with_data_import)

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
      travel 8.days do
        visit occupation_standard_path(occupation_standard)
        expect(page).to have_modal("Apprenticeship Standard Survey")

        dismiss_modal
        expect(page).to_not have_modal("Apprenticeship Standard Survey")

        # Fifth visit: no modal since second time entry has not passed
        visit occupation_standard_path(occupation_standard)
        expect(page).to_not have_modal("Apprenticeship Standard Survey")
      end


      # Sixth visit: enough time has passed and modal must appear (more than a month)
      travel 1.month + 9.days do
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
  end

  def dismiss_modal
    find('button#dismiss-modal').click
  end
end
