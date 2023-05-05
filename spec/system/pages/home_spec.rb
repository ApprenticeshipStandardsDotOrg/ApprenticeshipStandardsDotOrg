require "rails_helper"

RSpec.describe "pages/home" do
  it "filters occupations based on search term" do
    create(:state, name: "Washington")
    create(:state, name: "New York")
    create(:state, name: "Oregon")
    mechanic = create(:occupation_standard, :with_data_import, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, :with_data_import, title: "Pipe Fitter")

    visit home_page_path

    fill_in "q", with: "Mechanic"

    find("#search").click

    expect(page).to have_current_path(occupation_standards_path(q: "Mechanic"))
    expect(page).to have_text "Showing Results for Mechanic"
    expect(page).to have_field("q", with: "Mechanic")

    expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(page).to_not have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
  end

  describe "featured section" do
    it "displays National Guidelines box" do
      create(:state, name: "Washington")
      create(:state, name: "New York")
      create(:state, name: "Oregon")

      mechanic = create(:occupation_standard, :guideline_standard, title: "Mechanic")
      hr = create(:occupation_standard, :guideline_standard, title: "HR")
      create(:occupation_standard, :occupational_framework, title: "Pipe Fitter")

      visit home_page_path

      expect(page).to have_text "Featured"

      expect(page).to have_link "National Guidelines", href: occupation_standards_path(national_standard_type: {guideline_standard: 1})
      within("#guideline-standards") do
        expect(page).to have_text "2 Apprenticeships"
      end

      click_on "National Guidelines"

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "HR", href: occupation_standard_path(hr)
      expect(page).to_not have_link "Pipe Fitter"
    end

    it "displays Occupational Frameworks box" do
      create(:state, name: "Washington")
      create(:state, name: "New York")
      create(:state, name: "Oregon")

      mechanic = create(:occupation_standard, :occupational_framework, title: "Mechanic")
      hr = create(:occupation_standard, :occupational_framework, title: "HR")
      create(:occupation_standard, :guideline_standard, title: "Pipe Fitter")

      visit home_page_path

      expect(page).to have_link "Occupational Frameworks", href: occupation_standards_path(national_standard_type: {occupational_framework: 1})
      within("#occupational-frameworks") do
        expect(page).to have_text "2 Apprenticeships"
      end

      click_on "Occupational Frameworks"

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "HR", href: occupation_standard_path(hr)
      expect(page).to_not have_link "Pipe Fitter"
    end

    it "displays Washington box" do
      create(:state, name: "New York")
      create(:state, name: "Oregon")

      wa = create(:state, name: "Washington")
      ra = create(:registration_agency, state: wa)
      mechanic = create(:occupation_standard, registration_agency: ra, title: "Mechanic")
      hr = create(:occupation_standard, registration_agency: ra, title: "HR")
      create(:occupation_standard, title: "Pipe Fitter")

      visit home_page_path

      expect(page).to have_link "Washington", href: occupation_standards_path(state_id: wa.id)
      within("#washington") do
        expect(page).to have_text "2 Apprenticeships"
      end

      click_on "Washington"

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "HR", href: occupation_standard_path(hr)
      expect(page).to_not have_link "Pipe Fitter"
    end

    it "displays New York box" do
      create(:state, name: "Washington")
      create(:state, name: "Oregon")

      ny = create(:state, name: "New York")
      ra = create(:registration_agency, state: ny)
      mechanic = create(:occupation_standard, registration_agency: ra, title: "Mechanic")
      hr = create(:occupation_standard, registration_agency: ra, title: "HR")
      create(:occupation_standard, title: "Pipe Fitter")

      visit home_page_path

      expect(page).to have_link "New York", href: occupation_standards_path(state_id: ny.id)
      within("#new-york") do
        expect(page).to have_text "2 Apprenticeships"
      end

      click_on "New York"

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "HR", href: occupation_standard_path(hr)
      expect(page).to_not have_link "Pipe Fitter"
    end

    it "displays California box" do
      create(:state, name: "New York")
      create(:state, name: "Oregon")
      create(:state, name: "Washington")

      ca = create(:state, name: "California")
      ra = create(:registration_agency, state: ca)
      mechanic = create(:occupation_standard, registration_agency: ra, title: "Mechanic")
      hr = create(:occupation_standard, registration_agency: ra, title: "HR")
      create(:occupation_standard, title: "Pipe Fitter")

      visit home_page_path

      expect(page).to have_link "California", href: occupation_standards_path(state_id: ca.id)
      within("#california") do
        expect(page).to have_text "2 Apprenticeships"
      end

      click_on "California"

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "HR", href: occupation_standard_path(hr)
      expect(page).to_not have_link "Pipe Fitter"
    end

    it "displays Oregon box" do
      create(:state, name: "New York")
      create(:state, name: "Washington")

      ore = create(:state, name: "Oregon")
      ra = create(:registration_agency, state: ore)
      mechanic = create(:occupation_standard, registration_agency: ra, title: "Mechanic")
      hr = create(:occupation_standard, registration_agency: ra, title: "HR")
      create(:occupation_standard, title: "Pipe Fitter")

      visit home_page_path

      expect(page).to have_link "Oregon", href: occupation_standards_path(state_id: ore.id)
      within("#oregon") do
        expect(page).to have_text "2 Apprenticeships"
      end

      click_on "Oregon"

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "HR", href: occupation_standard_path(hr)
      expect(page).to_not have_link "Pipe Fitter"
    end
  end
end
