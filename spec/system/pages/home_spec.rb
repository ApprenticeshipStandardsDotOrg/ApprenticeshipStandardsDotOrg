require "rails_helper"

RSpec.describe "pages/home" do
  it "filters occupations based on search term" do
    allow(State).to receive(:find_by).and_return(build_stubbed(:state))
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter")

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
      allow(State).to receive(:find_by).and_return(build_stubbed(:state))
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, :guideline_standard, title: "Mechanic")
      hr = create(:occupation_standard, :with_work_processes, :with_data_import, :guideline_standard, title: "HR")
      create(:occupation_standard, :with_work_processes, :occupational_framework, title: "Pipe Fitter")

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
      allow(State).to receive(:find_by).and_return(build_stubbed(:state))

      organization = Organization.urban_institute || create(:organization, title: "Urban Institute")
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, :occupational_framework, title: "Mechanic", organization: organization)
      hr = create(:occupation_standard, :with_work_processes, :with_data_import, :occupational_framework, title: "HR", organization: organization)
      create(:occupation_standard, :with_work_processes, :with_data_import, :occupational_framework, title: "Dental Assistant")
      create(:occupation_standard, :with_work_processes, :guideline_standard, title: "Pipe Fitter")

      visit home_page_path

      expect(page).to have_link "Occupational Frameworks", href: occupation_standards_path(national_standard_type: {occupational_framework: 1})
      within("#occupational-frameworks") do
        expect(page).to have_text "2 Apprenticeships"
      end

      click_on "Occupational Frameworks"

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "HR", href: occupation_standard_path(hr)
      expect(page).to_not have_link "Dental Assistant"
      expect(page).to_not have_link "Pipe Fitter"
    end

    it "displays Washington box" do
      wa = create(:state, name: "Washington")
      state = build_stubbed(:state)
      allow(State).to receive(:find_by).with(name: "Washington").and_return(wa)
      allow(State).to receive(:find_by).with(name: "New York").and_return(state)
      allow(State).to receive(:find_by).with(name: "Oregon").and_return(state)
      allow(State).to receive(:find_by).with(name: "California").and_return(state)

      ra = create(:registration_agency, state: wa)
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "Mechanic")
      hr = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "HR")
      create(:occupation_standard, :with_work_processes, title: "Pipe Fitter")

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
      ny = create(:state, name: "New York")
      state = build_stubbed(:state)
      allow(State).to receive(:find_by).with(name: "Washington").and_return(state)
      allow(State).to receive(:find_by).with(name: "New York").and_return(ny)
      allow(State).to receive(:find_by).with(name: "Oregon").and_return(state)
      allow(State).to receive(:find_by).with(name: "California").and_return(state)

      ra = create(:registration_agency, state: ny)
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "Mechanic")
      hr = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "HR")
      create(:occupation_standard, :with_work_processes, title: "Pipe Fitter")

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
      ca = create(:state, name: "California")
      state = build_stubbed(:state)
      allow(State).to receive(:find_by).with(name: "Washington").and_return(state)
      allow(State).to receive(:find_by).with(name: "New York").and_return(state)
      allow(State).to receive(:find_by).with(name: "Oregon").and_return(state)
      allow(State).to receive(:find_by).with(name: "California").and_return(ca)

      ra = create(:registration_agency, state: ca)
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "Mechanic")
      hr = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "HR")
      create(:occupation_standard, :with_work_processes, title: "Pipe Fitter")

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
      ore = create(:state, name: "Oregon")
      state = build_stubbed(:state)
      allow(State).to receive(:find_by).with(name: "Washington").and_return(state)
      allow(State).to receive(:find_by).with(name: "New York").and_return(state)
      allow(State).to receive(:find_by).with(name: "Oregon").and_return(ore)
      allow(State).to receive(:find_by).with(name: "California").and_return(state)

      ra = create(:registration_agency, state: ore)
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "Mechanic")
      hr = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "HR")
      create(:occupation_standard, :with_work_processes, title: "Pipe Fitter")

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

    it "displays Installation etc. industry box" do
      allow(State).to receive(:find_by).and_return(build_stubbed(:state))

      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, onet_code: "49-1234", title: "Mechanic")
      hr = create(:occupation_standard, :with_work_processes, :with_data_import, onet_code: "49-5678", title: "HR")
      create(:occupation_standard, :with_work_processes, onet_code: "35-1234", title: "Pipe Fitter")

      visit home_page_path

      expect(page).to have_link "Installation, Maintenance, and Repair", href: occupation_standards_path(q: "49-")
      within("#industry-1") do
        expect(page).to have_text "2 Apprenticeships"
      end

      click_on "Installation"

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "HR", href: occupation_standard_path(hr)
      expect(page).to_not have_link "Pipe Fitter"
    end

    it "displays Healthcare Support industry box" do
      allow(State).to receive(:find_by).and_return(build_stubbed(:state))

      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, onet_code: "31-1234", title: "Mechanic")
      hr = create(:occupation_standard, :with_work_processes, :with_data_import, onet_code: "31-5678", title: "HR")
      create(:occupation_standard, :with_work_processes, onet_code: "35-1234", title: "Pipe Fitter")

      visit home_page_path

      expect(page).to have_link "Healthcare Support", href: occupation_standards_path(q: "31-")
      within("#industry-2") do
        expect(page).to have_text "2 Apprenticeships"
      end

      click_on "Healthcare Support"

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "HR", href: occupation_standard_path(hr)
      expect(page).to_not have_link "Pipe Fitter"
    end
  end
end
