require "rails_helper"

RSpec.describe "occupations/index", type: :view do
  it "displays the correct page title when page_title is present" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    assign :page_title, "Occupations"
    assign :occupation_standards, OccupationStandard.none
    assign :pagy, Pagy.new(count: 1)

    render template: "occupation_standards/index", layout: "layouts/application"

    expect(rendered).to have_title "Occupations - ApprenticeshipStandardsDotOrg"
  end

  it "displays standards titles" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
    pipe_fitter = create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Pipe Fitter")

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 2)

    render template: "occupation_standards/index"

    expect(rendered).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(rendered).to have_link "Pipe Fitter", href: occupation_standard_path(pipe_fitter)
  end

  it "displays only OJT hours and not skills for time-based standards" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    mechanic = create(:occupation_standard, :time, :with_data_import, title: "Mechanic")
    work_process = create(:work_process, occupation_standard: mechanic, maximum_hours: 200)
    create(:competency, work_process: work_process)

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 2)

    render template: "occupation_standards/index"

    expect(rendered).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(rendered).to have_text "OJT hours"
    expect(rendered).to_not have_text "Skills"
  end

  it "displays only skills and not OJT hours for competency-based standards" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    mechanic = create(:occupation_standard, :competency, :with_data_import, title: "Mechanic")
    work_process = create(:work_process, occupation_standard: mechanic, maximum_hours: 200)
    create(:competency, work_process: work_process)

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 2)

    render template: "occupation_standards/index"

    expect(rendered).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(rendered).to_not have_text "OJT hours"
    expect(rendered).to have_text "Skills"
  end

  it "displays skills and OJT hours for hybrid-based standards" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    mechanic = create(:occupation_standard, :hybrid, :with_data_import, title: "Mechanic")
    work_process = create(:work_process, occupation_standard: mechanic, maximum_hours: 200)
    create(:competency, work_process: work_process)

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 2)

    render template: "occupation_standards/index"

    expect(rendered).to have_link "Mechanic", href: occupation_standard_path(mechanic)
    expect(rendered).to have_text "OJT hours"
    expect(rendered).to have_text "Skills"
  end

  it "shows registration date if available" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", registration_date: Date.parse("October 17, 1989"))

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 1)

    render template: "occupation_standards/index"

    expect(rendered).to have_text "Registered 1989"
  end

  it "shows latest updated date if available" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", latest_update_date: Date.parse("October 17, 1989"))

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 1)

    render template: "occupation_standards/index"

    expect(rendered).to have_text "Updated 1989"
  end

  it "shows link to search by onet code if available" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "12.3456")

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 1)

    render template: "occupation_standards/index"

    expect(rendered).to have_link "12.3456", href: occupation_standards_path(q: mechanic.onet_code)
  end

  it "shows link to search by rapids code if available" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    mechanic = create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", rapids_code: "9876")

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 1)

    render template: "occupation_standards/index"

    expect(rendered).to have_link "9876", href: occupation_standards_path(q: mechanic.rapids_code)
  end

  it "shows similar results accordion button if they are present" do
    Flipper.enable :similar_programs_accordion
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
    create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Mechanic")

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 1)

    render template: "occupation_standards/index"

    expect(rendered).to have_text "1 program with similar or identical criteria."
    Flipper.disable :similar_programs_accordion
  end

  it "does not show similar results accordion button if they are not present" do
    Flipper.enable :similar_programs_accordion
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")
    create(:occupation_standard, :with_work_processes, :with_data_import, :program_standard, title: "Pipe Fitter")

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 1)

    render template: "occupation_standards/index"

    expect(rendered).not_to have_text "program with similar or identical criteria."
    Flipper.disable :similar_programs_accordion
  end

  it "shows alert if the occupation_standard hours do not meet the occupation required hours" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    occupation = create(:occupation, time_based_hours: 2000)
    occupation_standard = create(:occupation_standard, :with_data_import, occupation: occupation)
    create(:work_process, maximum_hours: 1000, occupation_standard: occupation_standard)

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 1)

    render template: "occupation_standards/index"

    expect(rendered).to have_selector "#hours-alert-#{occupation_standard.id}"
  end

  it "does not show alert if the occupation_standard hours meet the occupation required hours" do
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("occupation_standards")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    occupation = create(:occupation, time_based_hours: 2000)
    occupation_standard = create(:occupation_standard, :with_data_import, occupation: occupation)
    create(:work_process, maximum_hours: 3000, occupation_standard: occupation_standard)

    assign :occupation_standards, OccupationStandard.all
    assign :pagy, Pagy.new(count: 1)

    render template: "occupation_standards/index"

    expect(rendered).to_not have_selector "#hours-alert-#{occupation_standard.id}"
  end
end
