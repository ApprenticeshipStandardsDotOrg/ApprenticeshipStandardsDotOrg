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
end
