require "rails_helper"

RSpec.describe "pages/home" do
  context "without Elasticsearch enabled" do
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

        within("#occupational-frameworks") do
          expect(page).to have_text "2 Apprenticeships"
        end

        click_on "Occupational Frameworks"

        expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
        expect(page).to have_link "HR", href: occupation_standard_path(hr)
        expect(page).to_not have_link "Dental Assistant"
        expect(page).to_not have_link "Pipe Fitter"
      end

      it "displays popular states box" do
        wa = create(:state, name: "Washington", abbreviation: "WA")
        ca = create(:state, name: "California", abbreviation: "CA")

        ra = create(:registration_agency, state: wa)
        ca_ra = create(:registration_agency, state: ca)
        mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "Mechanic")
        hr = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "HR")
        create(:occupation_standard, :with_work_processes, registration_agency: ca_ra, title: "Pipe Fitter")

        visit home_page_path

        within("#washington") do
          expect(page).to have_text "2 Apprenticeships"
        end

        click_on "Washington"

        expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
        expect(page).to have_link "HR", href: occupation_standard_path(hr)
        expect(page).to_not have_link "Pipe Fitter"
      end

      it "displays popular industries box" do
        hc_industry = create(:industry, name: "Healthcare Support")
        rn = create(:occupation_standard, :with_work_processes, :with_data_import, onet_code: "31-1234", title: "RN", industry: hc_industry)
        hr = create(:occupation_standard, :with_work_processes, :with_data_import, onet_code: "31-5678", title: "HR", industry: hc_industry)
        create(:occupation_standard, :with_work_processes, onet_code: "35-1234", title: "Pipe Fitter")

        visit home_page_path

        within("#industry-#{hc_industry.id}") do
          expect(page).to have_text "2 Apprenticeships"
        end

        click_on "Healthcare Support"

        expect(page).to have_link "RN", href: occupation_standard_path(rn)
        expect(page).to have_link "HR", href: occupation_standard_path(hr)
        expect(page).to_not have_link "Pipe Fitter"
      end
    end
  end

  context "with Elasticsearch enabled", :elasticsearch do
    before(:each) do |example|
      stub_feature_flag(:use_elasticsearch_for_search, true)
      stub_feature_flag(:show_recently_added_section, true)
    end

    it "filters occupations based on search term" do
      allow(State).to receive(:find_by).and_return(build_stubbed(:state))
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
      pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Pipe Fitter")

      OccupationStandard.import
      OccupationStandard.__elasticsearch__.refresh_index!

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

        OccupationStandard.import
        OccupationStandard.__elasticsearch__.refresh_index!

        visit home_page_path

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

        OccupationStandard.import
        OccupationStandard.__elasticsearch__.refresh_index!

        visit home_page_path

        within("#occupational-frameworks") do
          expect(page).to have_text "2 Apprenticeships"
        end

        click_on "Occupational Frameworks"

        expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
        expect(page).to have_link "HR", href: occupation_standard_path(hr)
        expect(page).to_not have_link "Dental Assistant"
        expect(page).to_not have_link "Pipe Fitter"
      end

      it "displays popular states box" do
        wa = create(:state, name: "Washington", abbreviation: "WA")
        ca = create(:state, name: "California", abbreviation: "CA")

        ra = create(:registration_agency, state: wa)
        ca_ra = create(:registration_agency, state: ca)
        mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "Mechanic")
        hr = create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra, title: "HR")
        create(:occupation_standard, :with_work_processes, registration_agency: ca_ra, title: "Pipe Fitter")

        OccupationStandard.import
        OccupationStandard.__elasticsearch__.refresh_index!

        visit home_page_path

        within("#washington") do
          expect(page).to have_text "2 Apprenticeships"
        end

        click_on "Washington"

        expect(page).to have_link "Mechanic", href: occupation_standard_path(mechanic)
        expect(page).to have_link "HR", href: occupation_standard_path(hr)
        expect(page).to_not have_link "Pipe Fitter"
      end

      it "displays popular industries box" do
        hc_industry = create(:industry, name: "Healthcare Support")
        rn = create(:occupation_standard, :with_work_processes, :with_data_import, onet_code: "31-1234", title: "RN", industry: hc_industry)
        hr = create(:occupation_standard, :with_work_processes, :with_data_import, onet_code: "31-5678", title: "HR", industry: hc_industry)
        create(:occupation_standard, :with_work_processes, onet_code: "35-1234", title: "Pipe Fitter")

        OccupationStandard.import
        OccupationStandard.__elasticsearch__.refresh_index!

        visit home_page_path

        within("#industry-#{hc_industry.id}") do
          expect(page).to have_text "2 Apprenticeships"
        end

        click_on "Healthcare Support"

        expect(page).to have_link "RN", href: occupation_standard_path(rn)
        expect(page).to have_link "HR", href: occupation_standard_path(hr)
        expect(page).to_not have_link "Pipe Fitter"
      end
    end
  end

  describe "Popular Types" do
    it "displays a link to a search of occupation standards with national guidelines" do
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, national_standard_type: :guideline_standard)

      visit home_page_path

      click_on("National Guidelines 1 Apprenticeship")

      expect(page).to have_text mechanic.title
    end

    it "displays a link to a search of occupation standards with occupational frameworks" do
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, national_standard_type: :occupational_framework)

      visit home_page_path

      click_on("Occupational Frameworks 1 Apprenticeship")

      expect(page).to have_text mechanic.title
    end

    it "displays a link to a search of time based occupation standards" do
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, ojt_type: :time)

      visit home_page_path

      click_on("Time Based Occupations 1 Apprenticeship")

      expect(page).to have_text mechanic.title
    end

    it "displays a link to a search of competency based occupation standards" do
      mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, ojt_type: :competency)

      visit home_page_path

      click_on("Competency Based Occupations 1 Apprenticeship")

      expect(page).to have_text mechanic.title
    end
  end

  describe "Recently Added" do
    before(:each) do |example|
      stub_feature_flag(:show_recently_added_section, true)
      stub_feature_flag(:similar_programs_elasticsearch, false)
      stub_feature_flag(:use_elasticsearch_for_search, false)
    end

    it "displays a link to a search of occupation standards sorted by creation date" do
      create(:occupation_standard, :with_work_processes, :with_data_import, national_standard_type: :guideline_standard, title: "Mechanic")

      visit home_page_path

      click_link("See All", href: "/occupation_standards?sort=created_at")

      expect(page).to have_text "Mechanic"
    end

    it "displays a link to latest occupation standard" do
      create(:occupation_standard, :with_work_processes, :with_data_import, national_standard_type: :guideline_standard, title: "Mechanic")

      visit home_page_path

      click_on("Mechanic")

      expect(page).to have_text "Mechanic"
    end
  end
end
