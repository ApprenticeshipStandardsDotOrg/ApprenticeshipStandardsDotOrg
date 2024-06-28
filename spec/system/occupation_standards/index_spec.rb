require "rails_helper"

RSpec.describe "occupation_standards/index" do
  context "when not using elasticsearch for search" do
    it "displays pagination" do
      default_items = Pagy::DEFAULT[:items]
      Pagy::DEFAULT[:items] = 2
      create_list(:occupation_standard, 3)

      visit occupation_standards_path

      within(".pagy.nav") do
        expect(page).to have_link "2", href: occupation_standards_path(page: 2)
      end
      Pagy::DEFAULT[:items] = default_items
    end

    it "filters standards based on search term" do
      dental = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Dental Assistant")
      medical = create(:occupation_standard, :with_work_processes, :program_standard, :with_data_import, title: "Medical Assistant")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter")

      visit occupation_standards_path

      fill_in "q", with: "Assistant"

      find("#search").click

      expect(page).to have_text "Showing Results for Assistant"
      expect(page).to have_field("q", with: "Assistant")

      expect(page).to have_link "Dental Assistant", href: occupation_standard_path(dental)
      expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical)
      expect(page).to_not have_link "Pipe Fitter"
    end

    it "filters standards based on rapids_code search term" do
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", rapids_code: "1234")
      pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", rapids_code: "1234CB")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", rapids_code: "9876")

      visit occupation_standards_path

      fill_in "q", with: "1234"

      find("#search").click

      expect(page).to have_text "Showing Results for 1234"
      expect(page).to have_field("q", with: "1234")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
      expect(page).to_not have_link "HR"
    end

    it "filters standards based on onet_code search term" do
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456")
      pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.34")

      visit occupation_standards_path

      fill_in "q", with: "12.3456"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
      expect(page).to_not have_link "HR"
    end

    it "filters standards based on onet_code search term and state filter", :js, :elasticsearch do
      wa = create(:state, name: "Washington")
      ra = create(:registration_agency, state: wa)
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456", registration_agency: ra)
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.34")

      visit occupation_standards_path

      fill_in "q", with: "12.3456"
      click_on "Expand Filters"
      select "Washington"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456")
      expect(page).to have_field("state_id", with: wa.id)

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "filters standards based on onet_code search term and national_standard_type filter", :js, :elasticsearch do
      mechanic = create(:occupation_standard, :with_work_processes, :program_standard, :with_data_import, title: "Mechanic", onet_code: "12.3456")
      medical_assistant = create(:occupation_standard, :with_work_processes, :occupational_framework, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :guideline_standard, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.3456")

      visit occupation_standards_path

      fill_in "q", with: "12.3456"
      click_on "Expand Filters"
      find("#dropdownNationalButton").click
      check "National Program Standards"
      check "National Occupational Frameworks"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456")
      find("#dropdownNationalButton").click
      expect(page).to have_checked_field("National Program Standards")
      expect(page).to have_checked_field("National Occupational Frameworks")
      expect(page).to_not have_checked_field("National Guideline Standards")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "filters standards based on onet_code search term and ojt_type filter", :js, :elasticsearch do
      mechanic = create(:occupation_standard, :with_work_processes, :hybrid, :with_data_import, title: "Mechanic", onet_code: "12.3456")
      medical_assistant = create(:occupation_standard, :with_work_processes, :time, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :competency, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")

      visit occupation_standards_path

      fill_in "q", with: "12.3456"
      click_on "Expand Filters"
      find("#dropdownPrgrmTypeButton").click
      check "Hybrid"
      check "Time"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456")
      find("#dropdownPrgrmTypeButton").click
      expect(page).to have_checked_field("Hybrid")
      expect(page).to have_checked_field("Time")
      expect(page).to_not have_checked_field("Competency")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "filters standards with state shortcode" do
      washington_registration_agency = create(:registration_agency, for_state_abbreviation: "WA")
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456", registration_agency: washington_registration_agency)
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.34")

      visit occupation_standards_path

      fill_in "q", with: "state:wa 12.3456"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "state:wa 12.3456")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "filters standards with national_standard_type shortcode" do
      mechanic = create(:occupation_standard, :with_work_processes, :program_standard, :with_data_import, title: "Mechanic", onet_code: "12.3456")
      create(:occupation_standard, :with_work_processes, :occupational_framework, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :guideline_standard, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.3456")

      visit occupation_standards_path

      fill_in "q", with: "12.3456 national_standard_type:program_standard"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456 national_standard_type:program_standard")
      find("#dropdownNationalButton").click

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to_not have_link "Medical Assistant"
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "filters standards with ojt_type shortcode" do
      mechanic = create(:occupation_standard, :with_work_processes, :hybrid, :with_data_import, title: "Mechanic", onet_code: "12.3456")
      create(:occupation_standard, :with_work_processes, :time, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :competency, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")

      visit occupation_standards_path

      fill_in "q", with: "12.3456 ojt_type:hybrid"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456 ojt_type:hybrid")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to_not have_link "Medical Assistant"
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "can clear form", :js, :elasticsearch do
      wa = create(:state, name: "Washington")
      ra = create(:registration_agency, state: wa)
      mechanic = create(:occupation_standard, :with_work_processes, :hybrid, :with_data_import, title: "Mechanic", onet_code: "12.3456", registration_agency: ra)
      medical_assistant = create(:occupation_standard, :with_work_processes, :program_standard, :time, :with_data_import, title: "Medical Assistant", onet_code: "12.34567", registration_agency: ra)
      create(:occupation_standard, :with_work_processes, :competency, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")

      visit occupation_standards_path

      fill_in "q", with: "12.3456"
      click_on "Expand Filters"
      find("#dropdownPrgrmTypeButton").click
      check "Hybrid"
      check "Time"
      within("#dropdownPrgrmTypeButton") do
        expect(page).to have_text "2"
      end
      select "Washington"
      find("#dropdownNationalButton").click
      check "National Program Standards"
      within("#dropdownNationalButton") do
        expect(page).to have_text "1"
      end

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456")
      find("#dropdownPrgrmTypeButton").click
      expect(page).to have_checked_field("Hybrid")
      expect(page).to have_checked_field("Time")
      expect(page).to_not have_checked_field("Competency")
      expect(page).to have_select("state_id", selected: "Washington")
      find("#dropdownNationalButton").click
      expect(page).to have_checked_field("National Program Standards")
      expect(page).to_not have_checked_field("National Occupational Frameworks")
      expect(page).to_not have_checked_field("National Guideline Standards")

      expect(page).to_not have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
      expect(page).to_not have_link "Pipe Fitter"

      click_on "Clear All"
      expect(page).to have_field("q", with: "")
      find("#dropdownPrgrmTypeButton").click
      expect(page).to_not have_checked_field("Hybrid")
      expect(page).to_not have_checked_field("Time")
      expect(page).to_not have_checked_field("Competency")
      expect(page).to have_select("state_id", selected: "")
      within("#dropdownPrgrmTypeButton") do
        expect(page).to_not have_text "2"
        expect(page).to_not have_text "0"
      end
      find("#dropdownNationalButton").click
      expect(page).to_not have_checked_field("National Program Standards")
      expect(page).to_not have_checked_field("National Occupational Frameworks")
      expect(page).to_not have_checked_field("National Guideline Standards")
      within("#dropdownNationalButton") do
        expect(page).to_not have_text "1"
        expect(page).to_not have_text "0"
      end

      find("#search").click

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
      expect(page).to have_link "Pipe Fitter"
    end

    it "expands similar results accordion when accordion button is clicked", js: true do
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
      create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Mechanic")

      visit occupation_standards_path

      find('button[data-action="click->accordion#changeVisibility"]', match: :first).click

      expect(page).to have_selector(:button, "Collapse duplicates")
    end

    it "closes similar results accordion when accordion button is clicked", js: true do
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
      create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Mechanic")

      visit occupation_standards_path

      find('button[data-action="click->accordion#changeVisibility"]', match: :first).click
      click_on "Collapse duplicates"

      expect(page).not_to have_selector("#accordion-#{mechanic.id}")
    end

    it "displays toolip on hover", js: true do
      occupation = create(:occupation, time_based_hours: 2000)
      occupation_standard = create(:occupation_standard, :with_data_import, occupation: occupation)
      create(:work_process, maximum_hours: 1000, occupation_standard: occupation_standard)

      visit occupation_standards_path

      find("button[data-tooltip-target='hours-alert-#{occupation_standard.id}']").hover

      expect(page).to have_text "Hours do not meet minimum OA standard for this occupation"
    end
  end

  context "when using elasticsearch for search", :elasticsearch do
    before { stub_feature_flag(:use_elasticsearch_for_search, true) }
    after { stub_feature_flag(:use_elasticsearch_for_search, false) }

    it "displays pagination correctly when no collapsed items" do
      default_items = Pagy::DEFAULT[:items]
      Pagy::DEFAULT[:items] = 2
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR Specialist")
      create_pair(:occupation_standard, :with_work_processes, :with_data_import)

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      expect(page).to_not have_text "HR Specialist"

      within(".pagy.nav") do
        expect(page).to have_link "2", href: occupation_standards_path(page: 2)
        click_on "2"
      end
      expect(page).to have_text "HR Specialist"

      Pagy::DEFAULT[:items] = default_items
    end

    it "displays pagination correctly when there are collapsed items" do
      default_items = Pagy::DEFAULT[:items]
      Pagy::DEFAULT[:items] = 2

      # 2nd page
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR Specialist")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Dental Assistant")

      # 1st page
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter")
      os1 = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
      new_wp = create(:work_process, title: os1.work_processes.first.title)
      _os2 = create(:occupation_standard, :with_data_import, work_processes: [new_wp], title: "Mechanic")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      expect(page).to have_text "Mechanic"
      expect(page).to have_text "Pipe Fitter"
      expect(page).to_not have_text "HR Specialist"
      expect(page).to_not have_text "Dental Assistant"

      within(".pagy.nav") do
        expect(page).to have_link "2", href: occupation_standards_path(page: 2)
        expect(page).to_not have_link "3"
        click_on "2"
      end
      expect(page).to have_text "HR Specialist"
      expect(page).to have_text "Dental Assistant"

      Pagy::DEFAULT[:items] = default_items
    end

    it "filters standards based on search term" do
      dental = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Dental Assistant", onet_code: "12-3456.01")
      medical = create(:occupation_standard, :with_work_processes, :program_standard, :with_data_import, title: "Medical Assistant", onet_code: "12-9876.00")
      create(:occupation_standard, :with_work_processes, :program_standard, :with_data_import, title: "Other Assistant With Different ONET Code Prefix", onet_code: "13-9876.00")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      fill_in "q", with: "Assistant"

      find("#search").click

      expect(page).to have_text "Showing Results for Assistant"
      expect(page).to have_field("q", with: "Assistant")

      expect(page).to have_link "Dental Assistant", href: occupation_standard_path(dental)
      expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical)
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "Other Assistant"
    end

    it "can handle a search that returns no results" do
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      fill_in "q", with: "Assistant"

      find("#search").click

      expect(page).to have_text "Showing Results for Assistant"
      expect(page).to have_field("q", with: "Assistant")
      expect(page).to_not have_link "Mechanic"
    end

    it "filters standards based on rapids_code search term" do
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", rapids_code: "1234")
      pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", rapids_code: "1234CB")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", rapids_code: "9876")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      fill_in "q", with: "1234"

      find("#search").click

      expect(page).to have_text "Showing Results for 1234"
      expect(page).to have_field("q", with: "1234")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
      expect(page).to_not have_link "HR"
    end

    it "filters standards based on onet_code search term" do
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456")
      pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.34")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      fill_in "q", with: "12.3456"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
      expect(page).to_not have_link "HR"
    end

    it "filters standards based on onet_code search term and state filter", :js do
      wa = create(:state, name: "Washington")
      ra = create(:registration_agency, state: wa)
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456", registration_agency: ra)
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.34")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      fill_in "q", with: "12.3456"
      click_on "Expand Filters"
      select "Washington"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456")
      expect(page).to have_field("state_id", with: wa.id)

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "filters standards based on onet_code search term and national_standard_type filter", :js do
      mechanic = create(:occupation_standard, :with_work_processes, :program_standard, :with_data_import, title: "Mechanic", onet_code: "12.3456")
      medical_assistant = create(:occupation_standard, :with_work_processes, :occupational_framework, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :guideline_standard, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.3456")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      fill_in "q", with: "12.3456"
      click_on "Expand Filters"
      find("#dropdownNationalButton").click
      check "National Program Standards"
      check "National Occupational Frameworks"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456")
      find("#dropdownNationalButton").click
      expect(page).to have_checked_field("National Program Standards")
      expect(page).to have_checked_field("National Occupational Frameworks")
      expect(page).to_not have_checked_field("National Guideline Standards")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "filters standards based on onet_code search term and ojt_type filter", :js do
      mechanic = create(:occupation_standard, :with_work_processes, :hybrid, :with_data_import, title: "Mechanic", onet_code: "12.3456")
      medical_assistant = create(:occupation_standard, :with_work_processes, :time, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :competency, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      fill_in "q", with: "12.3456"
      click_on "Expand Filters"
      find("#dropdownPrgrmTypeButton").click
      check "Hybrid"
      check "Time"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456")
      find("#dropdownPrgrmTypeButton").click
      expect(page).to have_checked_field("Hybrid")
      expect(page).to have_checked_field("Time")
      expect(page).to_not have_checked_field("Competency")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "filters standards with state shortcode" do
      washington_registration_agency = create(:registration_agency, for_state_abbreviation: "WA")
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456", registration_agency: washington_registration_agency)
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.34")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      fill_in "q", with: "state:wa 12.3456"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "state:wa 12.3456")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "filters standards with national_standard_type shortcode" do
      mechanic = create(:occupation_standard, :with_work_processes, :program_standard, :with_data_import, title: "Mechanic", onet_code: "12.3456")
      create(:occupation_standard, :with_work_processes, :occupational_framework, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :guideline_standard, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "HR", onet_code: "12.3456")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      fill_in "q", with: "12.3456 national_standard_type:program_standard"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456 national_standard_type:program_standard")
      find("#dropdownNationalButton").click

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to_not have_link "Medical Assistant"
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "filters standards with ojt_type shortcode" do
      mechanic = create(:occupation_standard, :with_work_processes, :hybrid, :with_data_import, title: "Mechanic", onet_code: "12.3456")
      create(:occupation_standard, :with_work_processes, :time, :with_data_import, title: "Medical Assistant", onet_code: "12.34567")
      create(:occupation_standard, :with_work_processes, :competency, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      fill_in "q", with: "12.3456 ojt_type:hybrid"

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456 ojt_type:hybrid")

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to_not have_link "Medical Assistant"
      expect(page).to_not have_link "Pipe Fitter"
      expect(page).to_not have_link "HR"
    end

    it "can clear form", :js do
      wa = create(:state, name: "Washington")
      ra = create(:registration_agency, state: wa)
      mechanic = create(:occupation_standard, :with_work_processes, :hybrid, :with_data_import, title: "Mechanic", onet_code: "12.3456", registration_agency: ra)
      medical_assistant = create(:occupation_standard, :with_work_processes, :program_standard, :time, :with_data_import, title: "Medical Assistant", onet_code: "12.34567", registration_agency: ra)
      create(:occupation_standard, :with_work_processes, :competency, :with_data_import, title: "Pipe Fitter", onet_code: "12.34567")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      fill_in "q", with: "12.3456"
      click_on "Expand Filters"
      find("#dropdownPrgrmTypeButton").click
      check "Hybrid"
      check "Time"
      within("#dropdownPrgrmTypeButton") do
        expect(page).to have_text "2"
      end
      select "Washington"
      find("#dropdownNationalButton").click
      check "National Program Standards"
      within("#dropdownNationalButton") do
        expect(page).to have_text "1"
      end

      find("#search").click

      expect(page).to have_text "Showing Results for 12.3456"
      expect(page).to have_field("q", with: "12.3456")
      find("#dropdownPrgrmTypeButton").click
      expect(page).to have_checked_field("Hybrid")
      expect(page).to have_checked_field("Time")
      expect(page).to_not have_checked_field("Competency")
      expect(page).to have_select("state_id", selected: "Washington")
      find("#dropdownNationalButton").click
      expect(page).to have_checked_field("National Program Standards")
      expect(page).to_not have_checked_field("National Occupational Frameworks")
      expect(page).to_not have_checked_field("National Guideline Standards")

      expect(page).to_not have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
      expect(page).to_not have_link "Pipe Fitter"

      click_on "Clear All"
      expect(page).to have_field("q", with: "")
      find("#dropdownPrgrmTypeButton").click
      expect(page).to_not have_checked_field("Hybrid")
      expect(page).to_not have_checked_field("Time")
      expect(page).to_not have_checked_field("Competency")
      expect(page).to have_select("state_id", selected: "")
      within("#dropdownPrgrmTypeButton") do
        expect(page).to_not have_text "2"
        expect(page).to_not have_text "0"
      end
      find("#dropdownNationalButton").click
      expect(page).to_not have_checked_field("National Program Standards")
      expect(page).to_not have_checked_field("National Occupational Frameworks")
      expect(page).to_not have_checked_field("National Guideline Standards")
      within("#dropdownNationalButton") do
        expect(page).to_not have_text "1"
        expect(page).to_not have_text "0"
      end

      find("#search").click

      expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
      expect(page).to have_link "Medical Assistant", href: occupation_standard_path(medical_assistant)
      expect(page).to have_link "Pipe Fitter"
    end

    it "shows suggestions based on occupation title", :js do
      mechanic = create(:occupation, title: "Mechanic")
      pipe_fitter = create(:occupation, title: "Pipe Fitter")
      pippen_apple_collector = create(:occupation, title: "Pippen Apple Collector")

      Occupation.import
      Occupation.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      expect(page).to_not have_selector "div", class: "tt-suggestion"

      fill_in "q", with: "Me"

      expect(page).to have_selector "div", class: "tt-suggestion", text: mechanic.display_for_typeahead
      expect(page).to_not have_selector "div", class: "tt-suggestion", text: pipe_fitter.display_for_typeahead
      expect(page).to_not have_selector "div", class: "tt-suggestion", text: pippen_apple_collector.display_for_typeahead

      visit occupation_standards_path

      fill_in "q", with: "fi"

      expect(page).to_not have_selector "div", class: "tt-suggestion", text: mechanic.display_for_typeahead
      expect(page).to have_selector "div", class: "tt-suggestion", text: pipe_fitter.display_for_typeahead
      expect(page).to_not have_selector "div", class: "tt-suggestion", text: pippen_apple_collector.display_for_typeahead

      visit occupation_standards_path

      fill_in "q", with: "PIPE"

      expect(page).to_not have_selector "div", class: "tt-suggestion", text: mechanic.display_for_typeahead
      expect(page).to have_selector "div", class: "tt-suggestion", text: pipe_fitter.display_for_typeahead
      expect(page).to_not have_selector "div", class: "tt-suggestion", text: pippen_apple_collector.display_for_typeahead
    end

    it "shows suggestions based on onet code", :js do
      stub_feature_flag(:use_elasticsearch_for_search, true)

      mechanic_onet = create(:onet, code: "12-1234")
      mechanic = create(:occupation, title: "Mechanic", onet: mechanic_onet)
      pipe_fitter_onet = create(:onet, code: "51-6789")
      pipe_fitter = create(:occupation, title: "Pipe Fitter", onet: pipe_fitter_onet)

      Occupation.import
      Occupation.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      expect(page).to_not have_selector "div", class: "tt-suggestion"

      fill_in "q", with: "12-"

      expect(page).to have_selector "div", class: "tt-suggestion", text: mechanic.display_for_typeahead
      expect(page).to_not have_selector "div", class: "tt-suggestion", text: pipe_fitter.display_for_typeahead
    end

    it "shows suggestions based on rapids code", :js do
      mechanic = create(:occupation, title: "Mechanic", rapids_code: "9108")
      pipe_fitter = create(:occupation, title: "Pipe Fitter", rapids_code: "1582")

      Occupation.import
      Occupation.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      expect(page).to_not have_selector "div", class: "tt-suggestion"

      fill_in "q", with: "9108"

      expect(page).to have_selector "div", class: "tt-suggestion", text: mechanic.display_for_typeahead
      expect(page).to_not have_selector "div", class: "tt-suggestion", text: pipe_fitter.display_for_typeahead
    end

    xit "adds onet prefix to search when clicking on typeahead result", :js do
      mechanic_onet = create(:onet, code: "12-3456")
      mechanic = create(:occupation, title: "Mechanic", onet: mechanic_onet)
      pipe_fitter_onet = create(:onet, code: "98-7654")
      pipe_fitter = create(:occupation, title: "Pipe Fitter", onet: pipe_fitter_onet)

      # Mechanic with top title search, but non-matching ONET prefix
      create(:onet, code: "56-7890", related_job_titles: ["Super Mechanic", "Amazing Mechanic"])
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic One", onet_code: "56-7890")

      # Mechanic with matching ONET prefix
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic Two", onet_code: "12-9999")

      # Mechanic with non-matching ONET prefix
      create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic Three", onet_code: "13-9999")

      Occupation.import
      OccupationStandard.import
      Occupation.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      expect(page).to_not have_selector "div", class: "tt-suggestion"

      fill_in "q", with: "Me"

      expect(page).to have_selector "div", class: "tt-suggestion", text: mechanic.display_for_typeahead
      expect(page).to_not have_selector "div", class: "tt-suggestion", text: pipe_fitter.display_for_typeahead

      within(".tt-list") do
        find("div[data-typeahead-display-param='Mechanic']").click
      end

      expect(page).to have_text "Showing Results for Mechanic"
      expect(page).to have_no_text "Mechanic One"
      expect(page).to have_text "Mechanic Two"
      expect(page).to have_no_text "Mechanic Three"
    end

    it "expands similar results accordion when accordion button is clicked", js: true do
      os = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
      new_wp = create(:work_process, title: os.work_processes.first.title)
      create(:occupation_standard, :with_data_import, :program_standard, work_processes: [new_wp], title: "Mechanic")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      find('button[data-action="click->accordion#changeVisibility"]', match: :first).click

      expect(page).to have_selector(:button, "Collapse duplicates")
    end

    it "closes similar results accordion when accordion button is clicked", js: true do
      os = create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Mechanic")
      new_wp = create(:work_process, title: os.work_processes.first.title)
      mechanic = create(:occupation_standard, :with_data_import, work_processes: [new_wp], title: "Mechanic")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      find('button[data-action="click->accordion#changeVisibility"]', match: :first).click
      click_on "Collapse duplicates"

      expect(page).not_to have_selector("#accordion-#{mechanic.id}")
    end

    it "displays toolip on hover", js: true do
      occupation = create(:occupation, time_based_hours: 2000)
      occupation_standard = create(:occupation_standard, :with_data_import, occupation: occupation)
      create(:work_process, maximum_hours: 1000, occupation_standard: occupation_standard)

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

      visit occupation_standards_path

      find("button[data-tooltip-target='hours-alert-#{occupation_standard.id}']").hover

      expect(page).to have_text "Hours do not meet minimum OA standard for this occupation"
    end
  end
end
